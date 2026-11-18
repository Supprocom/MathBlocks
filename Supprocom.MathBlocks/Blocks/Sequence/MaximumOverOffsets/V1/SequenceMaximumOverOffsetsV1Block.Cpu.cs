using System.Buffers;
using System.Runtime.CompilerServices;

namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // Row row of sequence.maximum-over-offsets@1: the maximum of x[row + start] .. x[row + end] from a start of negative infinity,
    // by scalar.maximum's rule (Math.Max), so the maximum of -0.0 and 0.0 is 0.0. The row is invalid when a row of the span is
    // unreachable or unavailable.
    internal static bool MaximumOverOffsetsRow(
        ReadOnlySpan<double> x,
        ReadOnlySpan<bool> xValid,
        ReadOnlySpan<double> counts,
        int row,
        int start,
        int end,
        out double value)
    {
        value = 0d;
        if (!OffsetSpanIsReachable(counts, row, start, end))
            return false;
        var maximum = double.NegativeInfinity;
        for (long index = row + (long)start; index <= row + (long)end; index++)
        {
            if (!xValid[(int)index])
                return false;
            maximum = Math.Max(maximum, x[(int)index]);
        }
        value = maximum;
        return true;
    }

    // The values of sequence.maximum-over-offsets@1: each invalid row holds fill. The rows that are valid (the reach and availability rules of
    // MaximumOverOffsetsRow, decided by OffsetValidityRows) take the maximum of their span from two block tables at a cost per row that does not
    // depend on the data or the width of the span (van Herk and Gil-Werman): the spans are cut into blocks of the span's width, and a span is
    // the end of one block and the start of the next, so its maximum is the larger of the maximum from its first row to the end of its
    // block and the maximum from the start of the next block to its last row. Math.Max is exact for the values of a vector (they are never NaN)
    // and does not depend on the order it is applied in, so the result has the bits of the left to right maximum, a negative zero included.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    internal static void MaximumOverOffsetsValues(
        ReadOnlySpan<double> x,
        ReadOnlySpan<bool> xValid,
        ReadOnlySpan<double> counts,
        int start,
        int end,
        double fill,
        Span<double> values,
        Span<bool> rowValid)
    {
        var length = values.Length;
        OffsetValidityRows(x, xValid, counts, start, end, false, rowValid);
        var width = (long)end - start + 1;
        if (width > length)
        {
            values.Fill(fill);
            return;
        }

        var size = (int)width;
        var fromStart = ArrayPool<double>.Shared.Rent(length);
        var toEnd = ArrayPool<double>.Shared.Rent(length);
        try
        {
            for (var block = 0; block < length; block += size)
            {
                var blockEnd = (block + size < length ? block + size : length) - 1;
                fromStart[block] = x[block];
                for (var index = block + 1; index <= blockEnd; index++)
                    fromStart[index] = Math.Max(fromStart[index - 1], x[index]);
                toEnd[blockEnd] = x[blockEnd];
                for (var index = blockEnd - 1; index >= block; index--)
                    toEnd[index] = Math.Max(toEnd[index + 1], x[index]);
            }

            for (var row = 0; row < length; row++)
            {
                if (rowValid[row])
                {
                    var first = row + start;
                    values[row] = Math.Max(toEnd[first], fromStart[row + end]);
                }
                else
                {
                    values[row] = fill;
                }
            }
        }
        finally
        {
            ArrayPool<double>.Shared.Return(fromStart);
            ArrayPool<double>.Shared.Return(toEnd);
        }
    }
}
