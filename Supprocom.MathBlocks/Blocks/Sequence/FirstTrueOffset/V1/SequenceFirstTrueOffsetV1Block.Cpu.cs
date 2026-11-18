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

    // Every row of sequence.first-true-offset@1, and of its -valid form when writeValues is false (values is then untouched). The first
    // offset of every row is decided without a call, four rows at a time where the hardware has 256-bit blocks: most rows end there (the
    // predicate row is nonzero, or unavailable, or out of reach, or the span has a single offset). The rest go on with the same scan from the
    // next offset, so each row reads exactly the rows and gives exactly the result of FirstTrueOffsetRow.
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
    // scalar loop does for its row, with the same comparisons of the same doubles, so the values and flags are the same; a lane that needs
    // the scan from the next offset is finished by the scan itself.
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
        var zero = Vector256<double>.Zero;
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
            var nonzero = ~Vector256.Equals(Vector256.Create<double>(predicate[index..]), zero);
            var flagBytes = Vector128.CreateScalar(Unsafe.ReadUnaligned<uint>(ref Unsafe.As<bool, byte>(ref Unsafe.AsRef(in predicateValid[index])))).AsByte();
            var flagWords = Vector128.WidenLower(Vector128.WidenLower(flagBytes));
            var availability = Vector256.Create(Vector128.WidenLower(flagWords), Vector128.WidenUpper(flagWords));
            var available = ~Vector256.Equals(availability, Vector256<ulong>.Zero).AsDouble();
            var stop = nonzero | ~available;
            var ended = stop & available;
            var validLanes = single ? reachable & (ended | ~stop) : reachable & ended;
            var pending = single ? zero : reachable & ~stop;
            if (writeValues)
            {
                var resolved = Vector256.ConditionalSelect(stop, startVector, noMatchVector);
                Vector256.ConditionalSelect(validLanes, resolved, fillVector).CopyTo(values[row..]);
            }

            var flags = validLanes.ExtractMostSignificantBits();
            rowValid[row] = (flags & 1u) != 0u;
            rowValid[row + 1] = (flags & 2u) != 0u;
            rowValid[row + 2] = (flags & 4u) != 0u;
            rowValid[row + 3] = (flags & 8u) != 0u;
            var scans = pending.ExtractMostSignificantBits();
            while (scans != 0u)
            {
                var lane = BitOperations.TrailingZeroCount(scans);
                scans &= scans - 1u;
                var found = FirstTrueOffsetScan(predicate, predicateValid, counts, row + lane, (long)start + 1, end, noMatch, out var value);
                rowValid[row + lane] = found;
                if (writeValues)
                    values[row + lane] = found ? value : fill;
            }
        }

        return row;
    }
}
