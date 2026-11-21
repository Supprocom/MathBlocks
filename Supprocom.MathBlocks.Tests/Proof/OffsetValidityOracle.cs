namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The validity of sequence.sum-over-offsets@1 by the two earlier algorithms, kept as oracles of the current one: the plain scan of every row (the definition) and the path of
/// commit 366547c (scaled prefix sums over the whole series, monotonic deques over the span, a margin, and the sequential sum for the rows in the thin band).
/// </summary>
internal static class OffsetValidityOracle
{
    private const float PrefixScale = 7.7e-38f;
    private const float ScaledLimit = 16777216f;

    /// <summary>The definition: every row's span added left to right from 0.0, checked after every step.</summary>
    internal static bool[] Plain(float[] x, bool[] xValid, float[] counts, int start, int end)
    {
        var rowValid = new bool[x.Length];
        for (var row = 0; row < rowValid.Length; row++)
            rowValid[row] = Row(x, xValid, counts, row, start, end);
        return rowValid;
    }

    // One row by its definition: the span is reachable, every row in it is available, and no running sum is infinite or NaN.
    private static bool Row(float[] x, bool[] xValid, float[] counts, int row, int start, int end)
    {
        long before = start < 0 ? -(long)start : 0L;
        long after = end > 0 ? end : 0L;
        if (row + (long)start < 0 || counts[row] < before || row + after >= counts.Length || counts[(int)(row + after)] < after)
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

        return true;
    }

    // The rows whose span is reachable and available, by the definition (no overflow yet).
    private static bool[] ReachableAndAvailable(float[] x, bool[] xValid, float[] counts, int start, int end)
    {
        var rowValid = new bool[x.Length];
        for (var row = 0; row < rowValid.Length; row++)
        {
            long before = start < 0 ? -(long)start : 0L;
            long after = end > 0 ? end : 0L;
            var ok = row + (long)start >= 0 && counts[row] >= before && row + after < counts.Length && counts[(int)(row + after)] >= after;
            for (long index = row + (long)start; ok && index <= row + (long)end; index++)
                ok = xValid[(int)index];
            rowValid[row] = ok;
        }

        return rowValid;
    }

    /// <summary>The path of commit 366547c: reach and availability first, then the overflow decided over the whole series.</summary>
    internal static bool[] Prior(float[] x, bool[] xValid, float[] counts, int start, int end)
    {
        var rowValid = ReachableAndAvailable(x, xValid, counts, start, end);
        if (x.Length == 0)
            return rowValid;
        var magnitudes = 0f;
        for (var index = 0; index < x.Length; index++)
            magnitudes += Math.Abs(x[index]);
        if (magnitudes <= 2.62e38f)
            return rowValid;
        DecideOverflows(x, xValid, counts, start, end, rowValid);
        return rowValid;
    }

    private static void DecideOverflows(float[] x, bool[] xValid, float[] counts, int start, int end, bool[] rowValid)
    {
        var length = rowValid.Length;
        var width = (long)end - start + 1;
        var firstRow = start < 0 ? -(long)start : 0L;
        var lastRow = length - 1L - (end > 0 ? end : 0L);
        if (length - 1L - end < lastRow)
            lastRow = length - 1L - end;
        if (firstRow > lastRow)
            return;
        var prefix = new float[length + 1];
        var maximums = new int[length + 1];
        var minimums = new int[length + 1];
        var running = 0f;
        var largestPrefix = 0f;
        var largestValue = 0f;
        for (var index = 0; index < length; index++)
        {
            var scaled = x[index] * PrefixScale;
            running += scaled;
            prefix[index + 1] = running;
            largestPrefix = Math.Max(largestPrefix, Math.Abs(running));
            largestValue = Math.Max(largestValue, Math.Abs(scaled));
        }

        const float Epsilon = 2.220446049250313e-16f;
        var margin = 2f * (length + 2f) * Epsilon * largestPrefix
            + (width + 2f) * Epsilon * width * largestValue
            + length * 1.1754943e-38f
            + ScaledLimit * 4.5e-16f;
        var headMaximum = 0;
        var tailMaximum = 0;
        var headMinimum = 0;
        var tailMinimum = 0;
        var next = firstRow + start + 1;
        for (var row = (int)firstRow; row <= lastRow; row++)
        {
            var spanStart = row + (long)start;
            var spanEnd = spanStart + width;
            for (; next <= spanEnd; next++)
            {
                var value = prefix[(int)next];
                while (tailMaximum > headMaximum && prefix[maximums[tailMaximum - 1]] <= value)
                    tailMaximum--;
                maximums[tailMaximum++] = (int)next;
                while (tailMinimum > headMinimum && prefix[minimums[tailMinimum - 1]] >= value)
                    tailMinimum--;
                minimums[tailMinimum++] = (int)next;
            }

            while (maximums[headMaximum] <= spanStart)
                headMaximum++;
            while (minimums[headMinimum] <= spanStart)
                headMinimum++;
            if (!rowValid[row])
                continue;
            var before = prefix[(int)spanStart];
            var largest = Math.Max(prefix[maximums[headMaximum]] - before, before - prefix[minimums[headMinimum]]);
            if (largest + margin < ScaledLimit)
                continue;
            if (largest - margin > ScaledLimit)
            {
                rowValid[row] = false;
                continue;
            }

            rowValid[row] = Row(x, xValid, counts, row, start, end);
        }
    }
}
