using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Runtime.Intrinsics;

namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // Row row of sequence.sum-over-offsets@1: 0.0 plus x[row + start] .. x[row + end] added left to right, so 0.0 + -0.0 is 0.0.
    // The row is invalid when a row of the span is unreachable or unavailable, or when a running sum is not finite.
    internal static bool SumOverOffsetsRow(
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
        var sum = 0f;
        for (long index = row + (long)start; index <= row + (long)end; index++)
        {
            if (!xValid[(int)index])
                return false;
            sum += x[(int)index];
            if (!float.IsFinite(sum))
                return false;
        }
        value = sum;
        return true;
    }

    // The values of sequence.sum-over-offsets@1: each invalid row holds fill. The reach and the availability of every row come from OffsetValidityRows at a cost
    // that does not depend on the span. The sums are added in vector lanes, thirty-two rows and then four rows at a time: a lane holds one row and adds its span
    // from 0.0 left to right, so every sum has the bits of the sequential one (SumOverOffsetsRow). A running sum that is not finite stays so (an infinity plus a
    // finite value is that infinity, and a NaN stays a NaN), so a row has a running sum that is not finite exactly when its last sum is not finite. A lane also
    // adds the span of a row that is invalid already; that sum is not read.
    // The order of the additions is part of the definition, so the cost of a row grows with the width of its span; sequence.prefix-difference-over-offsets@1 gives the
    // sum of a span at a cost that does not depend on its width.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    internal static void SumOverOffsetsValues(
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
        if (length == 0)
            return;
        OffsetValidityRows(x, xValid, counts, start, end, false, rowValid);
        // The rows before the first whose span starts in the series are invalid.
        var row = (int)Math.Min(start < 0 ? -(long)start : 0L, length);
        values[..row].Fill(fill);
        if (MathBlockSimd.UseBlocks)
            row = SumOverOffsetsLanes(x, start, end, fill, values, rowValid, row);
        for (; row < length; row++)
        {
            if (rowValid[row] && SumOverOffsetsRow(x, xValid, counts, row, start, end, out var value))
            {
                values[row] = value;
            }
            else
            {
                rowValid[row] = false;
                values[row] = fill;
            }
        }
    }

    // The blocks of rows from row on whose spans lie in the series; returns the first row not done.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static int SumOverOffsetsLanes(ReadOnlySpan<float> x, int start, int end, float fill, Span<float> values, Span<bool> rowValid, int row)
    {
        // The last row at which a block of four may start: its last span ends in the series.
        var lastBlock = values.Length - (long)MathBlockSimd.BlockWidth - (end > 0 ? end : 0L);
        if (row > lastBlock)
            return row;
        // A span that lies in the series is not wider than it.
        var width = end - start + 1;
        var limit = Vector256.Create(float.MaxValue);
        var fillBlock = Vector256.Create(fill);
        ref var origin = ref MemoryMarshal.GetReference(x);
        ref var output = ref MemoryMarshal.GetReference(values);
        ref var flags = ref Unsafe.As<bool, byte>(ref MemoryMarshal.GetReference(rowValid));
        for (; row + 28L <= lastBlock; row += 32)
        {
            var at = (nuint)(row + (long)start);
            Vector256<float> s0 = default, s1 = default, s2 = default, s3 = default, s4 = default, s5 = default, s6 = default, s7 = default;
            for (var step = 0; step < width; step++, at++)
            {
                s0 += Vector256.LoadUnsafe(ref origin, at);
                s1 += Vector256.LoadUnsafe(ref origin, at + 4);
                s2 += Vector256.LoadUnsafe(ref origin, at + 8);
                s3 += Vector256.LoadUnsafe(ref origin, at + 12);
                s4 += Vector256.LoadUnsafe(ref origin, at + 16);
                s5 += Vector256.LoadUnsafe(ref origin, at + 20);
                s6 += Vector256.LoadUnsafe(ref origin, at + 24);
                s7 += Vector256.LoadUnsafe(ref origin, at + 28);
            }

            StoreFiniteSums(ref flags, ref output, row, s0, limit, fillBlock);
            StoreFiniteSums(ref flags, ref output, row + 4, s1, limit, fillBlock);
            StoreFiniteSums(ref flags, ref output, row + 8, s2, limit, fillBlock);
            StoreFiniteSums(ref flags, ref output, row + 12, s3, limit, fillBlock);
            StoreFiniteSums(ref flags, ref output, row + 16, s4, limit, fillBlock);
            StoreFiniteSums(ref flags, ref output, row + 20, s5, limit, fillBlock);
            StoreFiniteSums(ref flags, ref output, row + 24, s6, limit, fillBlock);
            StoreFiniteSums(ref flags, ref output, row + 28, s7, limit, fillBlock);
        }

        for (; row <= lastBlock; row += MathBlockSimd.BlockWidth)
        {
            var at = (nuint)(row + (long)start);
            var sum = Vector256<float>.Zero;
            for (var step = 0; step < width; step++)
                sum += Vector256.LoadUnsafe(ref origin, at + (nuint)step);
            StoreFiniteSums(ref flags, ref output, row, sum, limit, fillBlock);
        }

        return row;
    }

    // Four rows: a row that was valid and whose sum is finite keeps the sum and stays valid (a NaN fails the comparison too); every other row takes the fill and is invalid.
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    private static void StoreFiniteSums(ref byte flags, ref float output, int row, Vector256<float> sum, Vector256<float> limit, Vector256<float> fill)
    {
        ref var cell = ref Unsafe.Add(ref flags, row);
        var valid = Vector128.WidenLower(Vector128.WidenLower(Vector128.CreateScalar(Unsafe.ReadUnaligned<uint>(ref cell)).AsByte())).AsInt32();
        var keep = Widen(Vector128.GreaterThan(valid, Vector128<int>.Zero)).AsDouble() & Vector256.LessThanOrEqual(Vector256.Abs(sum), limit);
        Vector256.ConditionalSelect(keep, sum, fill).StoreUnsafe(ref output, (nuint)row);
        Unsafe.WriteUnaligned(ref cell, Unsafe.Add(ref MemoryMarshal.GetArrayDataReference(PrefixValidityPatterns), (int)keep.ExtractMostSignificantBits()));
    }
}
