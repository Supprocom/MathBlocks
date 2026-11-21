using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Runtime.Intrinsics;

namespace Supprocom.MathBlocks;

// The validity of sequence.sum-over-offsets@1 and sequence.maximum-over-offsets@1 (their -valid siblings) at a cost per row that does not
// depend on the data or on the width of the span. A row is valid when its span is reachable (OffsetSpanIsReachable) and every row in it is
// available; for the sum also when no running sum is infinite. The reach is two comparisons of the counts. The availability is one lookup:
// lastUnavailable[i] is the last row at or before i that is unavailable, so a span holds none exactly when lastUnavailable at its end is
// before its start. A running sum, added left to right from 0.0, is finite at every step whenever the sum of the magnitudes of all the
// values is below 2^1021: no partial sum can exceed that bound, also after rounding. A series whose magnitudes add up to more than that
// (values near the largest double) decides each valid row's overflow exactly: the sequential sum is finite exactly when no running sum
// overflowed, so spans up to LaneWidthLimit wide are added left to right in vector lanes (four rows per vector), and wider ones from
// scaled prefix sums over each run of valid rows, with the rows in a thin band added in order.
public static partial class MathBlockVectorMath
{
    // Every sum of magnitudes up to this bound keeps every running sum finite (the largest double is 2^1024).
    private const float FiniteSumBound = 2.2e307f;

    // The validity of sequence.sum-over-offsets@1 (sum is true) or sequence.maximum-over-offsets@1 (sum is false), row by row.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    internal static void OffsetValidityRows(
        ReadOnlySpan<float> x,
        ReadOnlySpan<bool> xValid,
        ReadOnlySpan<float> counts,
        int start,
        int end,
        bool sum,
        Span<bool> rowValid)
    {
        var length = rowValid.Length;
        if (length == 0)
            return;
        var overflowPossible = sum && !SumOfMagnitudesIsBelowTheBound(x);
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

        if (overflowPossible)
            DecideSumOverflows(x, xValid, counts, start, end, rowValid);
    }

    // The rows of the sum whose reach and availability are fine and that were decided exactly, and the rows sent to the sequential sum (read by tests).
    internal static long OverflowDecidedRows;
    internal static long OverflowBandRows;

    // The widest span whose rows are decided by adding every valid row's span left to right in vector lanes (four rows per vector, thirty-two rows at a time): the lanes hold
    // independent rows, each added in the order of the sequential sum, so the answer is the sequential one exactly and costs a few vector additions per row whatever the values
    // (thirty-two rows without a valid row among them are passed over).
    private const int LaneWidthLimit = 64;

    // Runs of valid rows up to this long are added row by row; longer runs of a wider span are decided from prefix sums.
    private const int ShortRun = 8;

    // The scale of the prefix sums: every value times 2^-1000, so that values near the largest double and their sums stay far from overflow.
    private const float PrefixScale = 9.332636185032189e-302f;

    // The largest double at that scale: 2^1024 * 2^-1000 = 2^24 (a sum rounds to infinity from just above the largest double).
    private const float ScaledLimit = 16777216f;

    // For the rows that are valid so far, decides whether a running sum, added left to right from 0.0, overflows. For values that are not infinite the sequential sum is not finite
    // exactly when some running sum overflowed (an infinity or NaN stays one), so a row is valid exactly when the sum of its span, added in order, is finite.
    private static void DecideSumOverflows(
        ReadOnlySpan<float> x,
        ReadOnlySpan<bool> xValid,
        ReadOnlySpan<float> counts,
        int start,
        int end,
        Span<bool> rowValid)
    {
        var width = (long)end - start + 1;
        long decided = 0;
        long band = 0;
        if (width <= LaneWidthLimit && MathBlockSimd.UseBlocks)
            decided += DecideByLanes(x, xValid, counts, start, end, rowValid, ref band);
        else
            DecideByRuns(x, xValid, counts, start, end, rowValid, ref decided, ref band);
        Interlocked.Add(ref OverflowDecidedRows, decided);
        Interlocked.Add(ref OverflowBandRows, band);
    }

    // Thirty-two rows, then four rows, at a time: every lane adds the span of its own row from 0.0 in order (the lanes of eight independent vectors keep the adders busy); a lane
    // whose sum is not finite clears the row. The rows before the first whose span starts in the series are invalid already, the last few rows are added one at a time.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static long DecideByLanes(
        ReadOnlySpan<float> x,
        ReadOnlySpan<bool> xValid,
        ReadOnlySpan<float> counts,
        int start,
        int end,
        Span<bool> rowValid,
        ref long band)
    {
        var length = rowValid.Length;
        var width = end - start + 1;
        var first = start < 0 ? -(long)start : 0L;
        var lastBlock = length - (long)MathBlockSimd.BlockWidth - (end > 0 ? end : 0L);
        var limit = Vector256.Create(float.MaxValue);
        ref var origin = ref MemoryMarshal.GetReference(x);
        ref var flags = ref Unsafe.As<bool, byte>(ref MemoryMarshal.GetReference(rowValid));
        uint decided = 0;
        var row = (int)Math.Min(first, (long)length);
        for (; row + 28L <= lastBlock; row += 32)
        {
            // Thirty-two rows that the reach and the availability left without a valid row have nothing to decide.
            ref var block = ref Unsafe.Add(ref flags, row);
            if ((Unsafe.ReadUnaligned<ulong>(ref block) | Unsafe.ReadUnaligned<ulong>(ref Unsafe.Add(ref block, 8))
                | Unsafe.ReadUnaligned<ulong>(ref Unsafe.Add(ref block, 16)) | Unsafe.ReadUnaligned<ulong>(ref Unsafe.Add(ref block, 24))) == 0UL)
            {
                continue;
            }

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

            decided += KeepFinite(ref flags, row, s0, limit) + KeepFinite(ref flags, row + 4, s1, limit) + KeepFinite(ref flags, row + 8, s2, limit) + KeepFinite(ref flags, row + 12, s3, limit)
                + KeepFinite(ref flags, row + 16, s4, limit) + KeepFinite(ref flags, row + 20, s5, limit) + KeepFinite(ref flags, row + 24, s6, limit) + KeepFinite(ref flags, row + 28, s7, limit);
        }

        for (; row <= lastBlock; row += MathBlockSimd.BlockWidth)
        {
            var at = (nuint)(row + (long)start);
            var sum = Vector256<float>.Zero;
            for (var step = 0; step < width; step++)
                sum += Vector256.LoadUnsafe(ref origin, at + (nuint)step);
            decided += KeepFinite(ref flags, row, sum, limit);
        }

        long scalar = 0;
        for (; row < length; row++)
        {
            if (!rowValid[row])
                continue;
            scalar++;
            rowValid[row] = SumOverOffsetsRow(x, xValid, counts, row, start, end, out _);
        }

        band += scalar;
        return decided + scalar;
    }

    // Clears the rows of four whose sum is not finite (a NaN fails the comparison too) and returns how many of them were valid before.
    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    private static uint KeepFinite(ref byte flags, int row, Vector256<float> sum, Vector256<float> limit)
    {
        var finite = Vector256.LessThanOrEqual(Vector256.Abs(sum), limit).ExtractMostSignificantBits();
        ref var cell = ref Unsafe.Add(ref flags, row);
        var before = Unsafe.ReadUnaligned<uint>(ref cell);
        // Four mask bits to the four bytes of a flag word (bit i to byte i; the products of distinct bits fall on distinct places).
        Unsafe.WriteUnaligned(ref cell, before & ((finite * 0x00204081u) & 0x01010101u));
        return (before * 0x01010101u) >> 24;
    }

    // The runs of consecutive valid rows, each decided on its own: a short run row by row, a long one from prefix sums over just its own values.
    private static void DecideByRuns(
        ReadOnlySpan<float> x,
        ReadOnlySpan<bool> xValid,
        ReadOnlySpan<float> counts,
        int start,
        int end,
        Span<bool> rowValid,
        ref long decided,
        ref long band)
    {
        var length = rowValid.Length;
        var row = 0;
        while (row < length)
        {
            while (row + 8 <= length && Unsafe.ReadUnaligned<ulong>(ref Unsafe.As<bool, byte>(ref Unsafe.AsRef(in rowValid[row]))) == 0ul)
                row += 8;
            while (row < length && !rowValid[row])
                row++;
            if (row >= length)
                return;
            var from = row;
            while (row < length && rowValid[row])
                row++;
            DecideRun(x, xValid, counts, start, end, from, row - 1, rowValid, ref decided, ref band);
        }
    }

    // Rows from to last (all valid so far). A long run: prefix[i] is the sum of the first i values of the run's own range at scale, added left to right. The running sums of a row are
    // the prefix sums minus the prefix sum before its span, up to the rounding of both: the largest and smallest prefix sum over the span (a monotonic deque slides along the rows)
    // bound them, and the rounding is bounded by a margin. A row whose largest running sum is below the limit by more than the margin cannot overflow, one above it by more than the
    // margin did overflow, and a row in the thin band between is added in order.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static void DecideRun(
        ReadOnlySpan<float> x,
        ReadOnlySpan<bool> xValid,
        ReadOnlySpan<float> counts,
        int start,
        int end,
        int from,
        int last,
        Span<bool> rowValid,
        ref long decided,
        ref long band)
    {
        var rows = last - from + 1;
        decided += rows;
        if (rows <= ShortRun)
        {
            for (var row = from; row <= last; row++)
                rowValid[row] = SumOverOffsetsRow(x, xValid, counts, row, start, end, out _);
            band += rows;
            return;
        }

        var width = (long)end - start + 1;
        var origin = from + (long)start;
        var count = (int)(rows - 1L + width);
        var prefix = System.Buffers.ArrayPool<float>.Shared.Rent(count + 1);
        var maximums = System.Buffers.ArrayPool<int>.Shared.Rent(count + 1);
        var minimums = System.Buffers.ArrayPool<int>.Shared.Rent(count + 1);
        try
        {
            var running = 0f;
            var largestPrefix = 0f;
            var largestValue = 0f;
            prefix[0] = 0f;
            for (var index = 0; index < count; index++)
            {
                var scaled = x[(int)(origin + index)] * PrefixScale;
                running += scaled;
                prefix[index + 1] = running;
                largestPrefix = Math.Max(largestPrefix, Math.Abs(running));
                largestValue = Math.Max(largestValue, Math.Abs(scaled));
            }

            // The margin, at scale: the rounding of the prefix sums and of the running sums, and the values too small to keep at scale.
            const float Epsilon = 2.220446049250313e-16f;
            var margin = 2f * (count + 2f) * Epsilon * largestPrefix
                + (width + 2f) * Epsilon * width * largestValue
                + count * 2.2250738585072014e-308f
                + ScaledLimit * 4.5e-16f;
            var headMaximum = 0;
            var tailMaximum = 0;
            var headMinimum = 0;
            var tailMinimum = 0;
            var next = 1;
            for (var row = from; row <= last; row++)
            {
                var spanStart = row - from;
                var spanEnd = spanStart + (int)width;
                for (; next <= spanEnd; next++)
                {
                    var value = prefix[next];
                    while (tailMaximum > headMaximum && prefix[maximums[tailMaximum - 1]] <= value)
                        tailMaximum--;
                    maximums[tailMaximum++] = next;
                    while (tailMinimum > headMinimum && prefix[minimums[tailMinimum - 1]] >= value)
                        tailMinimum--;
                    minimums[tailMinimum++] = next;
                }

                while (maximums[headMaximum] <= spanStart)
                    headMaximum++;
                while (minimums[headMinimum] <= spanStart)
                    headMinimum++;
                var before = prefix[spanStart];
                var largest = Math.Max(prefix[maximums[headMaximum]] - before, before - prefix[minimums[headMinimum]]);
                if (largest + margin < ScaledLimit)
                    continue;
                if (largest - margin > ScaledLimit)
                {
                    rowValid[row] = false;
                    continue;
                }

                band++;
                rowValid[row] = SumOverOffsetsRow(x, xValid, counts, row, start, end, out _);
            }
        }
        finally
        {
            System.Buffers.ArrayPool<float>.Shared.Return(prefix);
            System.Buffers.ArrayPool<int>.Shared.Return(maximums);
            System.Buffers.ArrayPool<int>.Shared.Return(minimums);
        }
    }

    // True when the magnitudes of all the values add up to less than FiniteSumBound.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static bool SumOfMagnitudesIsBelowTheBound(ReadOnlySpan<float> x)
    {
        var index = 0;
        var total = 0f;
        if (MathBlockSimd.UseBlocks)
        {
            var sums = Vector256<float>.Zero;
            for (; index <= x.Length - MathBlockSimd.BlockWidth; index += MathBlockSimd.BlockWidth)
                sums += Vector256.Abs(Vector256.Create<float>(x[index..]));
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
        ReadOnlySpan<float> counts,
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
    private static int ValidityBlocks(ReadOnlySpan<float> counts, int[] lastUnavailable, int start, int end, int row, long lastRow, Span<bool> rowValid)
    {
        var beforeVector = Vector256.Create(start < 0 ? -(float)start : 0f);
        var after = end > 0 ? end : 0;
        var afterVector = Vector256.Create((float)after);
        var lanes = Vector128.Create(0, 1, 2, 3);
        for (; row <= lastRow; row += MathBlockSimd.BlockWidth)
        {
            var reachable = Vector256.GreaterThanOrEqual(Vector256.Create<float>(counts[row..]), beforeVector)
                & Vector256.GreaterThanOrEqual(Vector256.Create<float>(counts[(row + after)..]), afterVector);
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
