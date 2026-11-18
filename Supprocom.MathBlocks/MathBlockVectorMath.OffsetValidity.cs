using System.Runtime.CompilerServices;
using System.Runtime.Intrinsics;

namespace Supprocom.MathBlocks;

// The validity of sequence.sum-over-offsets@1 and sequence.maximum-over-offsets@1 (their -valid siblings) at a cost per row that does not
// depend on the data or on the width of the span. A row is valid when its span is reachable (OffsetSpanIsReachable) and every row in it is
// available; for the sum also when no running sum is infinite. The reach is two comparisons of the counts. The availability is one lookup:
// lastUnavailable[i] is the last row at or before i that is unavailable, so a span holds none exactly when lastUnavailable at its end is
// before its start. A running sum, added left to right from 0.0, is finite at every step whenever the sum of the magnitudes of all the
// values is below 2^1021: no partial sum can exceed that bound, also after rounding. A series whose magnitudes add up to more than that
// (values near the largest double) takes the row by row scan of SumOverOffsetsRow, which gives the same answer.
public static partial class MathBlockVectorMath
{
    // Every sum of magnitudes up to this bound keeps every running sum finite (the largest double is 2^1024).
    private const double FiniteSumBound = 2.2e307;

    // The validity of sequence.sum-over-offsets@1 (sum is true) or sequence.maximum-over-offsets@1 (sum is false), row by row.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    internal static void OffsetValidityRows(
        ReadOnlySpan<double> x,
        ReadOnlySpan<bool> xValid,
        ReadOnlySpan<double> counts,
        int start,
        int end,
        bool sum,
        Span<bool> rowValid)
    {
        var length = rowValid.Length;
        if (length == 0)
            return;
        if (sum && !SumOfMagnitudesIsBelowTheBound(x))
        {
            for (var row = 0; row < length; row++)
                rowValid[row] = SumOverOffsetsRow(x, xValid, counts, row, start, end, out _);
            return;
        }

        var lastUnavailable = System.Buffers.ArrayPool<int>.Shared.Rent(length);
        try
        {
            FillLastUnavailable(xValid, lastUnavailable);
            var before = start < 0 ? -(long)start : 0L;
            var after = end > 0 ? (long)end : 0L;
            var row = 0;
            if (MathBlockSimd.UseBlocks && length >= MathBlockSimd.BlockWidth)
            {
                // The blocks start at the first row whose span starts in the series and stop before a block would reach past it.
                var first = Math.Min(before, (long)length);
                var last = length - after - MathBlockSimd.BlockWidth;
                row = (int)first;
                ValidityRowsScalar(counts, lastUnavailable, start, end, 0, row, rowValid);
                if (row <= last)
                    row = ValidityBlocks(counts, lastUnavailable, start, end, row, last, rowValid);
            }

            ValidityRowsScalar(counts, lastUnavailable, start, end, row, length, rowValid);
        }
        finally
        {
            System.Buffers.ArrayPool<int>.Shared.Return(lastUnavailable);
        }
    }

    // True when the magnitudes of all the values add up to less than FiniteSumBound.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static bool SumOfMagnitudesIsBelowTheBound(ReadOnlySpan<double> x)
    {
        var index = 0;
        var total = 0d;
        if (MathBlockSimd.UseBlocks)
        {
            var sums = Vector256<double>.Zero;
            for (; index <= x.Length - MathBlockSimd.BlockWidth; index += MathBlockSimd.BlockWidth)
                sums += Vector256.Abs(Vector256.Create<double>(x[index..]));
            total = Vector256.Sum(sums);
        }

        for (; index < x.Length; index++)
            total += Math.Abs(x[index]);
        return total <= FiniteSumBound;
    }

    // lastUnavailable[i]: the last row at or before i whose value is unavailable, or -1. Four rows at a time: each lane takes its own row when
    // that is unavailable, and two shifted selects give every lane the last such row in the block, or the carry from the rows before it.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static void FillLastUnavailable(ReadOnlySpan<bool> xValid, int[] lastUnavailable)
    {
        var length = xValid.Length;
        var carry = -1;
        var row = 0;
        if (MathBlockSimd.UseBlocks && length >= MathBlockSimd.BlockWidth)
        {
            var lanes = Vector128.Create(0, 1, 2, 3);
            var none = Vector128.Create(int.MinValue);
            var carryVector = Vector128.Create(-1);
            for (; row <= length - MathBlockSimd.BlockWidth; row += MathBlockSimd.BlockWidth)
            {
                var flagBytes = Vector128.CreateScalar(Unsafe.ReadUnaligned<uint>(ref Unsafe.As<bool, byte>(ref Unsafe.AsRef(in xValid[row])))).AsByte();
                var flags = Vector128.WidenLower(Vector128.WidenLower(flagBytes)).AsInt32();
                var tag = Vector128.ConditionalSelect(Vector128.Equals(flags, Vector128<int>.Zero), Vector128.Create(row) + lanes, none);
                tag = Vector128.ConditionalSelect(Vector128.Equals(tag, none), Vector128.Shuffle(tag, Vector128.Create(0, 0, 1, 2)), tag);
                tag = Vector128.ConditionalSelect(Vector128.Equals(tag, none), Vector128.Shuffle(tag, Vector128.Create(0, 0, 0, 1)), tag);
                tag = Vector128.ConditionalSelect(Vector128.Equals(tag, none), carryVector, tag);
                tag.CopyTo(lastUnavailable.AsSpan(row));
                carryVector = Vector128.Shuffle(tag, Vector128.Create(3, 3, 3, 3));
            }

            carry = carryVector.GetElement(0);
        }

        for (; row < length; row++)
        {
            if (!xValid[row])
                carry = row;
            lastUnavailable[row] = carry;
        }
    }

    // Rows from up to (not including) to, one at a time.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static void ValidityRowsScalar(
        ReadOnlySpan<double> counts,
        int[] lastUnavailable,
        int start,
        int end,
        int from,
        int to,
        Span<bool> rowValid)
    {
        var length = rowValid.Length;
        var before = start < 0 ? -(long)start : 0L;
        var after = end > 0 ? (long)end : 0L;
        for (var row = from; row < to; row++)
        {
            var valid = false;
            var last = row + after;
            if (row + (long)start >= 0 && counts[row] >= before && last < length && counts[(int)last] >= after)
                valid = lastUnavailable[(int)(row + (long)end)] < row + (long)start;
            rowValid[row] = valid;
        }
    }

    // Blocks of four rows from row on while the block starts at or before lastRow; returns the first row not done.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static int ValidityBlocks(ReadOnlySpan<double> counts, int[] lastUnavailable, int start, int end, int row, long lastRow, Span<bool> rowValid)
    {
        var beforeVector = Vector256.Create(start < 0 ? -(double)start : 0d);
        var after = end > 0 ? end : 0;
        var afterVector = Vector256.Create((double)after);
        var lanes = Vector128.Create(0, 1, 2, 3);
        for (; row <= lastRow; row += MathBlockSimd.BlockWidth)
        {
            var reachable = Vector256.GreaterThanOrEqual(Vector256.Create<double>(counts[row..]), beforeVector)
                & Vector256.GreaterThanOrEqual(Vector256.Create<double>(counts[(row + after)..]), afterVector);
            var unavailable = Vector128.Create<int>(lastUnavailable.AsSpan(row + end));
            var spanStarts = Vector128.Create(row + start) + lanes;
            var free = Vector128.LessThan(unavailable, spanStarts);
            var valid = reachable & Vector256.Create(Vector128.WidenLower(free), Vector128.WidenUpper(free)).AsDouble();
            var flags = valid.ExtractMostSignificantBits();
            rowValid[row] = (flags & 1u) != 0u;
            rowValid[row + 1] = (flags & 2u) != 0u;
            rowValid[row + 2] = (flags & 4u) != 0u;
            rowValid[row + 3] = (flags & 8u) != 0u;
        }

        return row;
    }
}
