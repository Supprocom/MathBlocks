using System.Buffers;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Runtime.Intrinsics;

namespace Supprocom.MathBlocks;

// The rows of sequence.prefix-difference-over-offsets@1 and its -valid sibling, with the arithmetic of the design in PrefixDifferenceCompute: inside a segment (it starts at row 0 and at
// every row whose count is 0) the prefix after row i is the running sum of the available values, left to right, an unavailable row adding nothing; row t is the prefix after row t + end
// less the prefix before row t + start, and is valid when both rows lie in t's segment, no row from t + start to t + end is unavailable, and the difference is finite.
//
// One sequential pass writes everything the rows need: the prefix after each row (one array, shifted by one so that the prefix before row i is the entry of row i - 1, and the
// entry in front of row 0 is zero), the segment number of each row (it grows by one at every start) and the last unavailable row up to each row. Row t is then a lookup in these three
// arrays at t + start and t + end, which the main pass does four rows at a time:
//   in a segment    the rows from min(t, t + start) to max(t, t + end) have one segment number (no start after the first of them);
//   no gap          the last unavailable row up to t + end is before t + start;
//   the prefix      before row t + start is the entry of row t + start - 1 unless row t + start starts its segment (their segment numbers differ), when it is +0.
// The sum is never -0 (it starts at +0 and +0 absorbs -0), so adding +0 for an unavailable row leaves it unchanged, bit for bit.
//
// Values below MathBlockSimd.TinyLimit in magnitude (the Subnormal class, whose sums and differences are subnormal or near it) are summed and subtracted in the scaled domain of
// MathBlockSimd (ScaleUp, ScaleDown), where the hardware never takes its slow path for a subnormal operand or result; the rows come out bit for bit the same.
public static partial class MathBlockVectorMath
{
    private static readonly uint[] PrefixValidityPatterns = BuildPrefixValidityPatterns();

    // The mask of four rows, as four bool bytes.
    private static uint[] BuildPrefixValidityPatterns()
    {
        var patterns = new uint[16];
        for (var mask = 0; mask < patterns.Length; mask++)
        {
            for (var lane = 0; lane < 4; lane++)
            {
                if ((mask & (1 << lane)) != 0)
                    patterns[mask] |= 1u << (8 * lane);
            }
        }

        return patterns;
    }

    // The counts are valid, the offsets are integers with start not above end, and the three series have equal length.
    internal static PrefixDifferenceRows PrefixDifferenceRowsOf(
        ReadOnlySpan<float> values,
        ReadOnlySpan<bool> available,
        ReadOnlySpan<float> counts,
        float start,
        float end,
        float fill,
        bool wantValues,
        bool wantValid)
    {
        var count = values.Length;
        if (available.Length != count || counts.Length != count)
            throw new ArgumentException("The three series must have equal length.", nameof(counts));
        if (count == 0)
            return new PrefixDifferenceRows([], [], null);
        var result = wantValues ? GC.AllocateUninitializedArray<float>(count) : ArrayPool<float>.Shared.Rent(count);
        var valid = wantValid ? new bool[count] : ArrayPool<bool>.Shared.Rent(count);
        var prefix = ArrayPool<float>.Shared.Rent(count + 1);
        var segment = ArrayPool<int>.Shared.Rent(count + 1);
        var lastGap = ArrayPool<int>.Shared.Rent(count);
        try
        {
            // A start below minus the row count, or an end at or above it, leaves every row without its rows in the series.
            if (start < -(float)count || end >= count)
            {
                result.AsSpan(0, count).Fill(fill);
                valid.AsSpan(0, count).Clear();
            }
            else
            {
                var tiny = MathBlockSimd.AllTiny(values);
                PrefixPass(values, available, counts, prefix, segment, lastGap, tiny);
                PrefixRowsPass(prefix, segment, lastGap, result, valid, count, (int)start, (int)end, fill, tiny);
            }

            return new PrefixDifferenceRows(wantValues ? result : [], wantValid ? valid : [], null);
        }
        finally
        {
            if (!wantValues)
                ArrayPool<float>.Shared.Return(result);
            if (!wantValid)
                ArrayPool<bool>.Shared.Return(valid);
            ArrayPool<float>.Shared.Return(prefix);
            ArrayPool<int>.Shared.Return(segment);
            ArrayPool<int>.Shared.Return(lastGap);
        }
    }

    // prefix[i + 1] is the prefix after row i (prefix[0] is +0), segment[i + 1] the segment number of row i (segment[0] is -1, which no row has), lastGap[i] the last unavailable row up
    // to row i (-1 when none). With tiny values the prefix is in the scaled domain.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static void PrefixPass(
        ReadOnlySpan<float> values,
        ReadOnlySpan<bool> available,
        ReadOnlySpan<float> counts,
        float[] prefix,
        int[] segment,
        int[] lastGap,
        bool tiny)
    {
        var count = values.Length;
        var source = values;
        if (tiny)
        {
            ScaleSeries(values, prefix.AsSpan(1, count));
            source = prefix.AsSpan(1, count);
        }

        prefix[0] = 0f;
        segment[0] = -1;
        var sum = 0f;
        var number = 0;
        var gap = -1;
        // The three series have the row count's length and the arrays at least one more (the caller guarantees both), so the references stay in range.
        ref var flags = ref Unsafe.As<bool, byte>(ref MemoryMarshal.GetReference(available));
        ref var input = ref MemoryMarshal.GetReference(source);
        ref var rowCounts = ref MemoryMarshal.GetReference(counts);
        ref var prefixRef = ref MemoryMarshal.GetArrayDataReference(prefix);
        ref var segmentRef = ref MemoryMarshal.GetArrayDataReference(segment);
        ref var gapRef = ref MemoryMarshal.GetArrayDataReference(lastGap);
        for (var row = 0; row < count; row++)
        {
            if (Unsafe.Add(ref rowCounts, row) == 0f)
            {
                sum = 0f;
                number++;
            }

            // +0 for an unavailable row, the value for an available one (the flag is 0 or 1).
            int keep = -(int)Unsafe.Add(ref flags, row);
            sum += BitConverter.Int32BitsToSingle(BitConverter.SingleToInt32Bits(Unsafe.Add(ref input, row)) & keep);
            gap = keep != 0 ? gap : row;
            Unsafe.Add(ref prefixRef, row + 1) = sum;
            Unsafe.Add(ref segmentRef, row + 1) = number;
            Unsafe.Add(ref gapRef, row) = gap;
        }
    }

    private static void ScaleSeries(ReadOnlySpan<float> values, Span<float> scaled)
    {
        var row = 0;
        if (MathBlockSimd.UseBlocks)
        {
            ref var input = ref MemoryMarshal.GetReference(values);
            ref var output = ref MemoryMarshal.GetReference(scaled);
            for (; row <= values.Length - MathBlockSimd.BlockWidth; row += MathBlockSimd.BlockWidth)
                MathBlockSimd.ScaleUp(Vector128.LoadUnsafe(ref input, (nuint)row)).StoreUnsafe(ref output, (nuint)row);
        }

        for (; row < values.Length; row++)
            scaled[row] = MathBlockSimd.ScaleUp(values[row]);
    }

    // Rows t from first to last (the ones whose rows t + start and t + end both exist) are computed; every other row is the fill, invalid. The offsets are within the series: start >= -count
    // and end < count.
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
    private static void PrefixRowsPass(
        float[] prefix,
        int[] segment,
        int[] lastGap,
        float[] result,
        bool[] valid,
        int count,
        int start,
        int end,
        float fill,
        bool tiny)
    {
        var first = Math.Max(0, -start);
        var last = Math.Min(count - 1, count - 1 - end);
        if (first > last)
        {
            result.AsSpan(0, count).Fill(fill);
            valid.AsSpan(0, count).Clear();
            return;
        }

        result.AsSpan(0, first).Fill(fill);
        valid.AsSpan(0, first).Clear();
        result.AsSpan(last + 1, count - last - 1).Fill(fill);
        valid.AsSpan(last + 1, count - last - 1).Clear();

        // The rows of the segment test: from t + lowReach to t + highReach, with the reach of t itself included.
        var lowReach = Math.Min(start, 0);
        var highReach = Math.Max(end, 0);
        var row = first;
        if (MathBlockSimd.UseBlocks && last - first + 1 >= MathBlockSimd.BlockWidth)
        {
            ref var prefixRef = ref MemoryMarshal.GetArrayDataReference(prefix);
            ref var segmentRef = ref MemoryMarshal.GetArrayDataReference(segment);
            ref var gapRef = ref MemoryMarshal.GetArrayDataReference(lastGap);
            ref var resultRef = ref MemoryMarshal.GetArrayDataReference(result);
            ref var validRef = ref Unsafe.As<bool, byte>(ref MemoryMarshal.GetArrayDataReference(valid));
            ref var patterns = ref MemoryMarshal.GetArrayDataReference(PrefixValidityPatterns);
            var fillBlock = Vector128.Create(fill);
            var exponent = Vector128.Create(0x7f80_0000u);
            var lanes = Vector128.Create(0, 1, 2, 3);
            var lastBlock = last - MathBlockSimd.BlockWidth + 1;
            // The final block starts at lastBlock and may overlap the one before it: a row's result does not depend on the others, so computing it twice stores the same row twice.
            while (true)
            {
                var low = row + start;
                var after = Vector128.LoadUnsafe(ref prefixRef, (nuint)(row + end + 1));
                var beforeRaw = Vector128.LoadUnsafe(ref prefixRef, (nuint)low);
                var numberLowPrevious = Vector128.LoadUnsafe(ref segmentRef, (nuint)low);
                var numberLow = Vector128.LoadUnsafe(ref segmentRef, (nuint)(low + 1));
                var numberFrom = Vector128.LoadUnsafe(ref segmentRef, (nuint)(row + lowReach + 1));
                var numberTo = Vector128.LoadUnsafe(ref segmentRef, (nuint)(row + highReach + 1));
                var gapTo = Vector128.LoadUnsafe(ref gapRef, (nuint)(row + end));

                var sameSegment = Vector128.Equals(numberFrom, numberTo);
                var noGap = Vector128.LessThan(gapTo, Vector128.Create(low) + lanes);
                var inRange = sameSegment & noGap;
                var continues = Vector128.Equals(numberLowPrevious, numberLow);
                var before = (beforeRaw.AsInt32() & continues).AsSingle();
                var difference = after - before;
                var finite = ~Vector128.Equals(difference.AsUInt32() & exponent, exponent);
                var ok = (inRange.AsUInt32() & finite).AsSingle();
                var rows = tiny ? MathBlockSimd.ScaleDown(difference) : difference;
                Vector128.ConditionalSelect(ok, rows, fillBlock).StoreUnsafe(ref resultRef, (nuint)row);
                Unsafe.WriteUnaligned(ref Unsafe.Add(ref validRef, row), Unsafe.Add(ref patterns, (int)ok.ExtractMostSignificantBits()));
                if (row == lastBlock)
                    break;
                row = Math.Min(row + MathBlockSimd.BlockWidth, lastBlock);
            }

            return;
        }

        for (; row <= last; row++)
        {
            var low = row + start;
            var high = row + end;
            var inRange = segment[row + lowReach + 1] == segment[row + highReach + 1] && lastGap[high] < low;
            var before = segment[low] == segment[low + 1] ? prefix[low] : 0f;
            var difference = prefix[high + 1] - before;
            if (inRange && float.IsFinite(difference))
            {
                result[row] = tiny ? MathBlockSimd.ScaleDown(difference) : difference;
                valid[row] = true;
            }
            else
            {
                result[row] = fill;
                valid[row] = false;
            }
        }
    }
}
