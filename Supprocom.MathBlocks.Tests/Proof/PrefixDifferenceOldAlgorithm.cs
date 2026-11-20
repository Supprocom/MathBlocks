namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The prefix difference as it was before the one-prefix-array rewrite (eight arrays, four passes, double arithmetic on the row positions), kept as a test-only oracle: the
/// rewrite must give the same bits and the same validity for every input. The segment, prefix and unavailable-row counts are the ones of the design in PrefixDifferenceCompute.
/// </summary>
internal static class PrefixDifferenceOldAlgorithm
{
    /// <summary>Evaluates the old algorithm over valid inputs (the counts are non-negative integers, start is an integer not above end).</summary>
    internal static (double[] Values, bool[] Valid) Run(double[] values, bool[] available, double[] counts, double start, double end, double fill)
    {
        var count = values.Length;
        var segmentStart = new int[count];
        var segmentEnd = new int[count];
        var before = new double[count];
        var after = new double[count];
        var missingBefore = new int[count];
        var missingAfter = new int[count];
        var sum = 0d;
        var missing = 0;
        var first = 0;
        for (var row = 0; row < count; row++)
        {
            if (row == 0 || counts[row] == 0d)
            {
                first = row;
                sum = 0d;
                missing = 0;
            }

            segmentStart[row] = first;
            before[row] = sum;
            missingBefore[row] = missing;
            if (available[row])
                sum += values[row];
            else
                missing++;
            after[row] = sum;
            missingAfter[row] = missing;
        }

        var last = count;
        for (var row = count - 1; row >= 0; row--)
        {
            segmentEnd[row] = last;
            if (row == segmentStart[row])
                last = row;
        }

        var result = new double[count];
        var valid = new bool[count];
        for (var row = 0; row < count; row++)
        {
            result[row] = fill;
            var low = row + start;
            var high = row + end;
            if (low < segmentStart[row] || high >= segmentEnd[row])
                continue;
            var lowRow = (int)low;
            var highRow = (int)high;
            if (missingBefore[lowRow] != missingAfter[highRow])
                continue;
            var difference = after[highRow] - before[lowRow];
            if (!double.IsFinite(difference))
                continue;
            result[row] = difference;
            valid[row] = true;
        }

        return (result, valid);
    }
}
