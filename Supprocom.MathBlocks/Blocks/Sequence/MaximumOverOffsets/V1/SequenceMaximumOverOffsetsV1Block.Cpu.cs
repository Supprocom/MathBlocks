using System.Buffers;
using System.Runtime.CompilerServices;
using System.Runtime.Intrinsics;

namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // Row row of sequence.maximum-over-offsets@1: the maximum of x[row + start] .. x[row + end] from a start of negative infinity,
    // by scalar.maximum's rule (Math.Max), so the maximum of -0.0 and 0.0 is 0.0. The row is invalid when a row of the span is
    // unreachable or unavailable.
    internal static bool MaximumOverOffsetsRow(
        ReadOnlySpan<float> x,
        ReadOnlySpan<bool> xValid,
        ReadOnlySpan<float> counts,
        int row,
        int start,
        int end,
        out float value)
    {
        value = 0f;
        if (!OffsetSpanIsReachable(counts, row, start, end))
            return false;
        var maximum = float.NegativeInfinity;
        for (long index = row + (long)start; index <= row + (long)end; index++)
        {
            if (!xValid[(int)index])
                return false;
            maximum = LargerKeepingTheFirstNaN(maximum, x[(int)index]);
        }
        value = maximum;
        return true;
    }

    // The larger of the running maximum and a value by scalar.maximum's rule (Math.Max) when both are numbers. A NaN is kept with its bits: the
    // first NaN of a span is the row's value whatever follows it. Math.Max leaves the bits of the NaN it returns to the runtime, and they differ
    // between its compiled forms, so the rule is written out here.
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static float LargerKeepingTheFirstNaN(float maximum, float value) =>
        float.IsNaN(maximum) ? maximum : float.IsNaN(value) ? value : Math.Max(maximum, value);

    // The values of sequence.maximum-over-offsets@1: each invalid row holds fill. The rows that are valid (the reach and availability rules of
    // MaximumOverOffsetsRow, decided by OffsetValidityRows) take the maximum of their span from two block tables at a cost per row that does not
    // depend on the data or the width of the span (van Herk and Gil-Werman): the spans are cut into blocks of the span's width, and a span is
    // the end of one block and the start of the next, so its maximum is the larger of the maximum from its first row to the end of its
    // block and the maximum from the start of the next block to its last row. For values that are not NaN Math.Max is exact and does not depend on the
    // order it is applied in, so the result has the bits of the left to right maximum, a negative zero included. A vector never holds a NaN, but a series that does
    // (a direct call) takes the scan of MaximumOverOffsetsRow, which decides which NaN payload the row keeps.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    internal static void MaximumOverOffsetsValues(
        ReadOnlySpan<float> x,
        ReadOnlySpan<bool> xValid,
        ReadOnlySpan<float> counts,
        int start,
        int end,
        float fill,
        Span<float> values,
        Span<bool> rowValid)
    {
        var length = values.Length;
        if (ContainsNaN(x))
        {
            for (var row = 0; row < length; row++)
            {
                rowValid[row] = MaximumOverOffsetsRow(x, xValid, counts, row, start, end, out var value);
                values[row] = rowValid[row] ? value : fill;
            }

            return;
        }

        OffsetValidityRows(x, xValid, counts, start, end, false, rowValid);
        var width = (long)end - start + 1;
        if (width > length)
        {
            values.Fill(fill);
            return;
        }

        var size = (int)width;
        if (size == 1)
        {
            // A span of one row: the maximum of negative infinity and a value that is not NaN is that value with its bits.
            var first = (int)Math.Min(start < 0 ? -(long)start : 0L, length);
            var last = (int)Math.Max(first, length - (start > 0 ? (long)start : 0L));
            values[..first].Fill(fill);
            for (var row = first; row < last; row++)
                values[row] = rowValid[row] ? x[row + start] : fill;
            values[last..].Fill(fill);
            return;
        }

        var fromStart = ArrayPool<float>.Shared.Rent(length);
        var toEnd = ArrayPool<float>.Shared.Rent(length);
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
            ArrayPool<float>.Shared.Return(fromStart);
            ArrayPool<float>.Shared.Return(toEnd);
        }
    }

    private static bool ContainsNaN(ReadOnlySpan<float> values)
    {
        var index = 0;
        if (MathBlockSimd.UseBlocks && values.Length >= MathBlockSimd.BlockWidth)
        {
            for (; index <= values.Length - MathBlockSimd.BlockWidth; index += MathBlockSimd.BlockWidth)
            {
                var block = Vector256.Create<float>(values[index..]);
                if (!Vector256.EqualsAll(block, block))
                    return true;
            }
        }

        for (; index < values.Length; index++)
        {
            if (float.IsNaN(values[index]))
                return true;
        }

        return false;
    }
}
