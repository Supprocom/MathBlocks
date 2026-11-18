using System.Buffers;
using System.Runtime.CompilerServices;
using System.Runtime.Intrinsics;

namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // The first offset that no longer has a stop in its window is encoded with this kind; see FirstTrueOffsetRows.
    private const int StopUnavailable = 0;
    private const int StopTrue = 1;
    private const int StopSegmentEnd = 2;

    // Row row of sequence.first-true-offset@1: the first offset in start..end whose predicate row is nonzero (a negative zero is
    // false), or noMatch when none is. An unreachable row or an unavailable predicate row met before a match makes the row
    // invalid; the rows after the first match are never read. This is the definition; FirstTrueOffsetRows gives the same results.
    internal static bool FirstTrueOffsetRow(
        ReadOnlySpan<double> predicate,
        ReadOnlySpan<bool> predicateValid,
        ReadOnlySpan<double> counts,
        int row,
        int start,
        int end,
        double noMatch,
        out double value)
    {
        value = 0d;
        for (long offset = start; offset <= end; offset++)
        {
            if (!OffsetIsReachable(counts, row, offset))
                return false;
            var target = (int)(row + offset);
            if (!predicateValid[target])
                return false;
            if (predicate[target] != 0d)
            {
                value = offset;
                return true;
            }
        }
        value = noMatch;
        return true;
    }

    // The values of sequence.first-true-offset@1: each invalid row holds fill.
    internal static void FirstTrueOffsetValues(
        ReadOnlySpan<double> predicate,
        ReadOnlySpan<bool> predicateValid,
        ReadOnlySpan<double> counts,
        int start,
        int end,
        double noMatch,
        double fill,
        Span<double> values,
        Span<bool> rowValid) =>
        FirstTrueOffsetRows(predicate, predicateValid, counts, start, end, noMatch, fill, values, rowValid, true);

    // Every row of sequence.first-true-offset@1, and of its -valid form when writeValues is false (values is then untouched), at a cost per
    // row that does not depend on the data or on the width of the span.
    //
    // The counts of a series that is cut into segments (the counts of the rows of one segment are 0, 1, 2, ... and a new segment starts
    // wherever a count is 0) make the reach simple: a row reaches the rows from its segment's start to its segment's end, and the first
    // offset of a row is reachable exactly when the existing comparison of the counts says so (counts[row] >= -start, or
    // counts[row + start] >= start), which is also the test below. One backward pass then gives every row the next stop at or after it inside
    // its segment: the next row whose predicate is nonzero (kind true) or unavailable (kind unavailable), or else the row after the
    // segment's end (kind segment end). A row whose first offset is reachable reads the stop of row + start: a stop within the window ends the
    // scan there (a match when it is true, an invalid row otherwise, and the segment's end is the first unreachable offset); no stop within
    // the window is a valid row with noMatch. Counts that are not cut into segments take the row by row scan of FirstTrueOffsetRow.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    internal static void FirstTrueOffsetRows(
        ReadOnlySpan<double> predicate,
        ReadOnlySpan<bool> predicateValid,
        ReadOnlySpan<double> counts,
        int start,
        int end,
        double noMatch,
        double fill,
        Span<double> values,
        Span<bool> rowValid,
        bool writeValues)
    {
        var length = rowValid.Length;
        if (length == 0)
            return;
        if (length > MaximumSegmentRows || !CountsFormSegments(counts))
        {
            for (var row = 0; row < length; row++)
            {
                rowValid[row] = FirstTrueOffsetRow(predicate, predicateValid, counts, row, start, end, noMatch, out var value);
                if (writeValues)
                    values[row] = rowValid[row] ? value : fill;
            }

            return;
        }

        var next = ArrayPool<int>.Shared.Rent(length);
        try
        {
            FillNextStops(predicate, predicateValid, counts, next);
            var row = 0;
            var endClamped = end < length + 1L ? end : length + 1;
            if (MathBlockSimd.UseBlocks && length >= MathBlockSimd.BlockWidth)
            {
                // The blocks start at the first row whose first target exists and stop before a block would reach past the series.
                var first = start < 0 ? -(long)start : 0L;
                var last = length - (start > 0 ? (long)start : 0L) - MathBlockSimd.BlockWidth;
                row = (int)Math.Min(first, (long)length);
                RowsFromNextStops(counts, next, start, endClamped, noMatch, fill, values, rowValid, writeValues, 0, row);
                if (row <= last)
                    row = BlocksFromNextStops(counts, next, start, endClamped, noMatch, fill, values, rowValid, writeValues, row, last);
            }

            RowsFromNextStops(counts, next, start, endClamped, noMatch, fill, values, rowValid, writeValues, row, length);
        }
        finally
        {
            ArrayPool<int>.Shared.Return(next);
        }
    }

    // A stop is stored as index * 4 + kind in an int.
    private const int MaximumSegmentRows = 1 << 28;

    // True when counts[t] is 0 or counts[t - 1] + 1 for every t from 1 on.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static bool CountsFormSegments(ReadOnlySpan<double> counts)
    {
        var index = 1;
        var broken = Vector256<double>.Zero;
        if (MathBlockSimd.UseBlocks)
        {
            var one = Vector256.Create(1d);
            for (; index <= counts.Length - MathBlockSimd.BlockWidth; index += MathBlockSimd.BlockWidth)
            {
                var block = Vector256.Create<double>(counts[index..]);
                var previous = Vector256.Create<double>(counts[(index - 1)..]);
                broken |= ~(Vector256.Equals(block, Vector256<double>.Zero) | Vector256.Equals(block, previous + one));
            }
        }

        if (broken.ExtractMostSignificantBits() != 0u)
            return false;
        for (; index < counts.Length; index++)
        {
            if (counts[index] != 0d && counts[index] != counts[index - 1] + 1d)
                return false;
        }

        return true;
    }

    // next[i]: the first row at or after i, inside i's segment, that is unavailable or nonzero (index * 4 + kind), else the row after the
    // segment's end (index * 4 + segment end). A segment ends at the last row or before a row whose count is 0. The last rows go one at a
    // time, the others four at a time: each lane takes its own tag (its stop, its segment end, or none), and two shifted selects give every
    // lane the first tag at or after it in the block, or the carry from the rows after the block.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static void FillNextStops(ReadOnlySpan<double> predicate, ReadOnlySpan<bool> predicateValid, ReadOnlySpan<double> counts, int[] next)
    {
        var length = predicate.Length;
        var carry = (length << 2) | StopSegmentEnd;
        var blocked = MathBlockSimd.UseBlocks && length > MathBlockSimd.BlockWidth;
        var scalarFrom = blocked ? length - (length % MathBlockSimd.BlockWidth == 0 ? MathBlockSimd.BlockWidth : length % MathBlockSimd.BlockWidth) : 0;
        for (var row = length - 1; row >= scalarFrom; row--)
        {
            if (row == length - 1 || counts[row + 1] == 0d)
                carry = ((row + 1) << 2) | StopSegmentEnd;
            var available = predicateValid[row];
            if (!available || predicate[row] != 0d)
                carry = (row << 2) | (available ? StopTrue : StopUnavailable);
            next[row] = carry;
        }

        if (!blocked)
            return;
        var lanes = Vector128.Create(0, 1, 2, 3);
        var one = Vector128.Create(1);
        var endKind = Vector128.Create(StopSegmentEnd);
        var carryVector = Vector128.Create(carry);
        for (var row = scalarFrom - MathBlockSimd.BlockWidth; row >= 0; row -= MathBlockSimd.BlockWidth)
        {
            var nonzero = ~Vector256.Equals(Vector256.Create<double>(predicate[row..]), Vector256<double>.Zero);
            var flagBytes = Vector128.CreateScalar(Unsafe.ReadUnaligned<uint>(ref Unsafe.As<bool, byte>(ref Unsafe.AsRef(in predicateValid[row])))).AsByte();
            var flags = Vector128.WidenLower(Vector128.WidenLower(flagBytes)).AsInt32();
            var unavailable = Vector128.Equals(flags, Vector128<int>.Zero);
            var stops = Vector128.Narrow(nonzero.GetLower().AsInt64(), nonzero.GetUpper().AsInt64()) | unavailable;
            var segmentEnds = Vector256.Equals(Vector256.Create<double>(counts[(row + 1)..]), Vector256<double>.Zero);
            var ends = Vector128.Narrow(segmentEnds.GetLower().AsInt64(), segmentEnds.GetUpper().AsInt64());
            var indices = Vector128.Create(row) + lanes;
            var tag = Vector128.ConditionalSelect(
                stops,
                Vector128.ShiftLeft(indices, 2) | flags,
                Vector128.ConditionalSelect(ends, Vector128.ShiftLeft(indices + one, 2) | endKind, Vector128.Create(-1)));
            tag = Vector128.ConditionalSelect(Vector128.LessThan(tag, Vector128<int>.Zero), Vector128.Shuffle(tag, Vector128.Create(1, 2, 3, 3)), tag);
            tag = Vector128.ConditionalSelect(Vector128.LessThan(tag, Vector128<int>.Zero), Vector128.Shuffle(tag, Vector128.Create(2, 3, 3, 3)), tag);
            tag = Vector128.ConditionalSelect(Vector128.LessThan(tag, Vector128<int>.Zero), carryVector, tag);
            tag.CopyTo(next.AsSpan(row));
            carryVector = Vector128.Shuffle(tag, Vector128.Create(0, 0, 0, 0));
        }
    }

    // Rows from up to (not including) to, one at a time, from the stops.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static void RowsFromNextStops(
        ReadOnlySpan<double> counts,
        int[] next,
        int start,
        int end,
        double noMatch,
        double fill,
        Span<double> values,
        Span<bool> rowValid,
        bool writeValues,
        int from,
        int to)
    {
        var length = rowValid.Length;
        var needed = start < 0 ? -(long)start : 0L;
        for (var row = from; row < to; row++)
        {
            var target = row + (long)start;
            var valid = false;
            var value = fill;
            if ((ulong)target < (ulong)length && (start < 0 ? counts[row] >= needed : counts[(int)target] >= start))
            {
                var stop = next[(int)target];
                var found = stop >> 2;
                if (found <= row + (long)end)
                {
                    valid = (stop & 3) == StopTrue;
                    value = found - row;
                }
                else
                {
                    valid = true;
                    value = noMatch;
                }
            }

            rowValid[row] = valid;
            if (writeValues)
                values[row] = valid ? value : fill;
        }
    }

    // Blocks of four rows from row on while the block starts at or before lastRow; returns the first row not done. Each lane does what
    // RowsFromNextStops does for its row.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static int BlocksFromNextStops(
        ReadOnlySpan<double> counts,
        int[] next,
        int start,
        int end,
        double noMatch,
        double fill,
        Span<double> values,
        Span<bool> rowValid,
        bool writeValues,
        int row,
        long lastRow)
    {
        var startVector = Vector256.Create((double)start);
        var neededVector = Vector256.Create((double)(start < 0 ? -(long)start : 0L));
        var noMatchVector = Vector256.Create(noMatch);
        var fillVector = Vector256.Create(fill);
        var lanes = Vector128.Create(0, 1, 2, 3);
        var endVector = Vector128.Create(end);
        var kindMask = Vector128.Create(3);
        var trueKind = Vector128.Create(StopTrue);
        for (; row <= lastRow; row += MathBlockSimd.BlockWidth)
        {
            var index = row + start;
            var counted = Vector256.Create<double>(counts[(start < 0 ? row : index)..]);
            var reachable = Vector256.GreaterThanOrEqual(counted, start < 0 ? neededVector : startVector);
            var stops = Vector128.Create<int>(next.AsSpan(index));
            var found = Vector128.ShiftRightArithmetic(stops, 2);
            var rows = Vector128.Create(row) + lanes;
            var within = Vector128.LessThanOrEqual(found, rows + endVector);
            var matched = within & Vector128.Equals(stops & kindMask, trueKind);
            var valid = reachable & AsDoubleMask(~within | matched);
            if (writeValues)
            {
                var offsets = Vector128.ConvertToDouble(Vector128.WidenLower(found - rows));
                var offsetsUpper = Vector128.ConvertToDouble(Vector128.WidenUpper(found - rows));
                var resolved = Vector256.ConditionalSelect(AsDoubleMask(matched), Vector256.Create(offsets, offsetsUpper), noMatchVector);
                Vector256.ConditionalSelect(valid, resolved, fillVector).CopyTo(values[row..]);
            }

            var flags = valid.ExtractMostSignificantBits();
            rowValid[row] = (flags & 1u) != 0u;
            rowValid[row + 1] = (flags & 2u) != 0u;
            rowValid[row + 2] = (flags & 4u) != 0u;
            rowValid[row + 3] = (flags & 8u) != 0u;
        }

        return row;
    }

    // The four 32-bit lane masks as four 64-bit lane masks (each lane's all-ones or zero is kept).
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    private static Vector256<double> AsDoubleMask(Vector128<int> mask) =>
        Vector256.Create(Vector128.WidenLower(mask), Vector128.WidenUpper(mask)).AsDouble();
}
