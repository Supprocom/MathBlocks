using System.Numerics;
using System.Runtime.CompilerServices;
using System.Runtime.Intrinsics;

namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // Row row of sequence.first-true-offset@1: the first offset in start..end whose predicate row is nonzero (a negative zero is
    // false), or noMatch when none is. An unreachable row or an unavailable predicate row met before a match makes the row
    // invalid; the rows after the first match are never read.
    internal static bool FirstTrueOffsetRow(
        ReadOnlySpan<double> predicate,
        ReadOnlySpan<bool> predicateValid,
        ReadOnlySpan<double> counts,
        int row,
        int start,
        int end,
        double noMatch,
        out double value) =>
        FirstTrueOffsetScan(predicate, predicateValid, counts, row, start, end, noMatch, out value);

    // The scan of FirstTrueOffsetRow from the offset first on: offsets first..end are tried in order.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static bool FirstTrueOffsetScan(
        ReadOnlySpan<double> predicate,
        ReadOnlySpan<bool> predicateValid,
        ReadOnlySpan<double> counts,
        int row,
        long first,
        int end,
        double noMatch,
        out double value)
    {
        value = 0d;
        for (var offset = first; offset <= end; offset++)
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

    // The loops below are compiled fully optimized at their first call (AggressiveOptimization): each runs once per evaluation, so the tiered
    // compiler would time the first few dozen evaluations with unoptimized and instrumented code.
    // Every row of sequence.first-true-offset@1, and of its -valid form when writeValues is false (values is then untouched). The first
    // offset of every row is decided without a call, four rows at a time where the hardware has 256-bit blocks: most rows end there (the
    // predicate row is nonzero, or unavailable, or out of reach, or the span has a single offset). The rest go on with the same scan from the
    // next offset, so each row reads exactly the rows and gives exactly the result of FirstTrueOffsetRow.
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
        var row = 0;
        if (MathBlockSimd.UseBlocks && length >= MathBlockSimd.BlockWidth)
        {
            // The blocks start at the first row whose first target exists and stop before a block would reach past the series.
            var first = start < 0 ? -(long)start : 0L;
            var last = length - (start > 0 ? (long)start : 0L) - MathBlockSimd.BlockWidth;
            row = (int)Math.Min(first, (long)length);
            FirstTrueOffsetRowsScalar(predicate, predicateValid, counts, start, end, noMatch, fill, values, rowValid, writeValues, 0, row);
            if (row <= last)
                row = FirstTrueOffsetBlocks(predicate, predicateValid, counts, start, end, noMatch, fill, values, rowValid, writeValues, row, last);
        }

        FirstTrueOffsetRowsScalar(predicate, predicateValid, counts, start, end, noMatch, fill, values, rowValid, writeValues, row, length);
    }

    // Rows from up to (not including) to, one at a time.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static void FirstTrueOffsetRowsScalar(
        ReadOnlySpan<double> predicate,
        ReadOnlySpan<bool> predicateValid,
        ReadOnlySpan<double> counts,
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
        var startValue = (double)start;
        var single = start == end;
        var needed = start < 0 ? -(long)start : 0L;
        for (var row = from; row < to; row++)
        {
            var target = row + (long)start;
            var valid = false;
            var value = fill;
            if ((ulong)target < (ulong)length)
            {
                var index = (int)target;
                if (start < 0 ? counts[row] >= needed : counts[index] >= start)
                {
                    var available = predicateValid[index];
                    if (!available | predicate[index] != 0d)
                    {
                        valid = available;
                        value = startValue;
                    }
                    else if (single)
                    {
                        valid = true;
                        value = noMatch;
                    }
                    else
                    {
                        valid = FirstTrueOffsetScan(predicate, predicateValid, counts, row, (long)start + 1, end, noMatch, out value);
                    }
                }
            }

            rowValid[row] = valid;
            if (writeValues)
                values[row] = valid ? value : fill;
        }
    }

    // Blocks of four rows from row on while the block starts at or before lastRow; returns the first row not done. Each lane does what the
    // scalar loop does for its row, with the same comparisons of the same doubles, so the values and flags are the same.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static int FirstTrueOffsetBlocks(
        ReadOnlySpan<double> predicate,
        ReadOnlySpan<bool> predicateValid,
        ReadOnlySpan<double> counts,
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
        var single = start == end;
        for (; row <= lastRow; row += MathBlockSimd.BlockWidth)
        {
            var index = row + start;
            var counted = Vector256.Create<double>(counts[(start < 0 ? row : index)..]);
            var reachable = Vector256.GreaterThanOrEqual(counted, start < 0 ? neededVector : startVector);
            var stop = StopsAt(predicate, predicateValid, index, out var available);
            var ended = stop & available;
            var valid = single ? reachable & (ended | ~stop) : reachable & ended;
            var value = Vector256.ConditionalSelect(stop, startVector, noMatchVector);
            if (!single)
            {
                var pending = reachable & ~stop;
                if (pending.ExtractMostSignificantBits() != 0u)
                    FirstTrueOffsetContinue(predicate, predicateValid, counts, start, end, noMatch, row, pending, ref valid, ref value);
            }

            if (writeValues)
                Vector256.ConditionalSelect(valid, value, fillVector).CopyTo(values[row..]);
            var flags = valid.ExtractMostSignificantBits();
            rowValid[row] = (flags & 1u) != 0u;
            rowValid[row + 1] = (flags & 2u) != 0u;
            rowValid[row + 2] = (flags & 4u) != 0u;
            rowValid[row + 3] = (flags & 8u) != 0u;
        }

        return row;
    }

    // The lanes (rows of a block) in pending went past their first offset: they are reachable there and their predicate row is available
    // and zero. Offsets start + 1 to end go on four rows at a time while the targets of all four rows exist, then lane by lane with the
    // scan. A lane that ends sets its bit in valid when its row is available, with its offset in value; a lane that goes out of reach is
    // left invalid; a lane that meets no match is valid with noMatch.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static void FirstTrueOffsetContinue(
        ReadOnlySpan<double> predicate,
        ReadOnlySpan<bool> predicateValid,
        ReadOnlySpan<double> counts,
        int start,
        int end,
        double noMatch,
        int row,
        Vector256<double> pending,
        ref Vector256<double> valid,
        ref Vector256<double> value)
    {
        var length = predicate.Length;
        var steps = (long)end - start;
        var step = 1L;
        for (; step <= steps; step++)
        {
            if (pending.ExtractMostSignificantBits() == 0u)
                return;
            var offset = start + step;
            var target = row + offset;
            if (target + MathBlockSimd.BlockWidth > length)
                break;
            var index = (int)target;
            var reachable = offset < 0
                ? Vector256<double>.AllBitsSet
                : Vector256.GreaterThanOrEqual(Vector256.Create<double>(counts[index..]), Vector256.Create((double)offset));
            var stop = StopsAt(predicate, predicateValid, index, out var available);
            var finished = pending & reachable & stop;
            valid |= finished & available;
            value = Vector256.ConditionalSelect(finished, Vector256.Create((double)offset), value);
            pending &= reachable & ~stop;
        }

        var lanes = pending.ExtractMostSignificantBits();
        if (step > steps)
        {
            valid |= pending;
            value = Vector256.ConditionalSelect(pending, Vector256.Create(noMatch), value);
            return;
        }

        while (lanes != 0u)
        {
            var lane = BitOperations.TrailingZeroCount(lanes);
            lanes &= lanes - 1u;
            var found = FirstTrueOffsetScan(predicate, predicateValid, counts, row + lane, (long)start + step, end, noMatch, out var result);
            valid = valid.WithElement(lane, found ? BitConverter.Int64BitsToDouble(-1L) : 0d);
            value = value.WithElement(lane, result);
        }
    }

    // The lanes whose predicate row (four rows from index on) is unavailable or nonzero; available holds the lanes whose predicate row is
    // available. Both are lane masks.
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    private static Vector256<double> StopsAt(ReadOnlySpan<double> predicate, ReadOnlySpan<bool> predicateValid, int index, out Vector256<double> available)
    {
        var nonzero = ~Vector256.Equals(Vector256.Create<double>(predicate[index..]), Vector256<double>.Zero);
        var flagBytes = Vector128.CreateScalar(Unsafe.ReadUnaligned<uint>(ref Unsafe.As<bool, byte>(ref Unsafe.AsRef(in predicateValid[index])))).AsByte();
        var flagWords = Vector128.WidenLower(Vector128.WidenLower(flagBytes));
        var flags = Vector256.Create(Vector128.WidenLower(flagWords), Vector128.WidenUpper(flagWords));
        available = ~Vector256.Equals(flags, Vector256<ulong>.Zero).AsDouble();
        return nonzero | ~available;
    }
}
