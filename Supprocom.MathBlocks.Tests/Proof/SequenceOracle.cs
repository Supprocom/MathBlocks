namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// An independent evaluation of the six sequence operations, written from the design's semantics and not from the library's code: per row it checks the chaining rule
/// of the counts, the availability of every row read, and the arithmetic, and gives the value (the fill where the row is not valid) and the row's validity.
/// </summary>
internal static class SequenceOracle
{
    /// <summary>Runs the named operation with integer parameters: k as <paramref name="first"/> for lead and lag, start and end for the others.</summary>
    internal static (double[] Values, bool[] Valid) Run(string name, double[] series, bool[] availability, double[] counts, long first, long second) =>
        name switch
        {
            "lead" => Lead(series, availability, counts, first),
            SequenceOps.Lag => Lag(series, availability, counts, first),
            SequenceOps.FirstTrue => FirstTrue(series, availability, counts, first, second),
            "sum-over-offsets" => Reduce(series, availability, counts, first, second, sum: true),
            "maximum-over-offsets" => Reduce(series, availability, counts, first, second, sum: false),
            "prefix-difference-over-offsets" => PrefixDifference(series, availability, counts, first, second),
            _ => throw new ArgumentOutOfRangeException(nameof(name), name, "The operation is not one of the six.")
        };

    // Rows t..t+k are chained when t+k exists and counts[t+k] >= k.
    private static (double[] Values, bool[] Valid) Lead(double[] x, bool[] availability, double[] counts, long k)
    {
        var values = new double[x.Length];
        var valid = new bool[x.Length];
        for (var row = 0; row < x.Length; row++)
        {
            var target = row + k;
            var ok = target < x.Length && counts[(int)target] >= k && availability[(int)target];
            valid[row] = ok;
            values[row] = ok ? x[(int)target] : SequenceOps.Fill;
        }

        return (values, valid);
    }

    // Rows t-k..t are chained when counts[t] >= k.
    private static (double[] Values, bool[] Valid) Lag(double[] x, bool[] availability, double[] counts, long k)
    {
        var values = new double[x.Length];
        var valid = new bool[x.Length];
        for (var row = 0; row < x.Length; row++)
        {
            var ok = row >= k && counts[row] >= k && availability[(int)(row - k)];
            valid[row] = ok;
            values[row] = ok ? x[(int)(row - k)] : SequenceOps.Fill;
        }

        return (values, valid);
    }

    // Offsets are tried in order; an offset that is not reachable or reads an unavailable row invalidates the row, and the first non-zero predicate (negative zero is false) ends the scan.
    private static (double[] Values, bool[] Valid) FirstTrue(double[] p, bool[] availability, double[] counts, long start, long end)
    {
        var values = new double[p.Length];
        var valid = new bool[p.Length];
        for (var row = 0; row < p.Length; row++)
        {
            var ok = true;
            var result = SequenceOps.NoMatch;
            for (var offset = start; offset <= end; offset++)
            {
                var target = row + offset;
                var reachable = target >= 0 && target < p.Length && (offset < 0 ? counts[row] >= -offset : counts[(int)target] >= offset);
                if (!reachable || !availability[(int)target])
                {
                    ok = false;
                    break;
                }

                if (p[(int)target] != 0d)
                {
                    result = offset;
                    break;
                }
            }

            valid[row] = ok;
            values[row] = ok ? result : SequenceOps.Fill;
        }

        return (values, valid);
    }

    // The span start..end must lie in the series and be chained, every row in it must be available, and a sum must stay finite at every step. The sum starts at positive zero;
    // the maximum starts at negative infinity and uses Math.Max, which orders negative zero below positive zero.
    private static (double[] Values, bool[] Valid) Reduce(double[] x, bool[] availability, double[] counts, long start, long end, bool sum)
    {
        var values = new double[x.Length];
        var valid = new bool[x.Length];
        var before = start < 0 ? -start : 0L;
        var after = end > 0 ? end : 0L;
        for (var row = 0; row < x.Length; row++)
        {
            var last = row + after;
            var ok = row + start >= 0 && counts[row] >= before && last < x.Length && counts[(int)last] >= after;
            var result = sum ? 0d : double.NegativeInfinity;
            for (var offset = start; ok && offset <= end; offset++)
            {
                var index = (int)(row + offset);
                if (!availability[index])
                {
                    ok = false;
                }
                else if (sum)
                {
                    result += x[index];
                    ok = double.IsFinite(result);
                }
                else
                {
                    result = Math.Max(result, x[index]);
                }
            }

            valid[row] = ok;
            values[row] = ok ? result : SequenceOps.Fill;
        }

        return (values, valid);
    }

    // A segment starts at row 0 and at every row with a zero count. Inside a segment the prefix starts at zero and adds zero for an unavailable row. The window start..end is valid
    // when both ends lie in the row's segment, no unavailable row lies between them, and the difference of the two prefixes is finite.
    private static (double[] Values, bool[] Valid) PrefixDifference(double[] x, bool[] availability, double[] counts, long start, long end)
    {
        var n = x.Length;
        var segmentStart = new int[n];
        var segmentEnd = new int[n];
        var prefixBefore = new double[n];
        var prefixThrough = new double[n];
        var missingBefore = new int[n];
        var missingThrough = new int[n];
        for (var row = 0; row < n; row++)
        {
            var begins = row == 0 || counts[row] == 0d;
            segmentStart[row] = begins ? row : segmentStart[row - 1];
            prefixBefore[row] = begins ? 0d : prefixThrough[row - 1];
            missingBefore[row] = begins ? 0 : missingThrough[row - 1];
            prefixThrough[row] = prefixBefore[row] + (availability[row] ? x[row] : 0d);
            missingThrough[row] = missingBefore[row] + (availability[row] ? 0 : 1);
        }

        for (var row = n - 1; row >= 0; row--)
            segmentEnd[row] = row + 1 < n && counts[row + 1] != 0d ? segmentEnd[row + 1] : row;
        var values = new double[n];
        var valid = new bool[n];
        for (var row = 0; row < n; row++)
        {
            var low = row + start;
            var high = row + end;
            var ok = low >= segmentStart[row] && high <= segmentEnd[row];
            var difference = 0d;
            if (ok)
            {
                difference = prefixThrough[(int)high] - prefixBefore[(int)low];
                ok = missingBefore[(int)low] == missingThrough[(int)high] && double.IsFinite(difference);
            }

            valid[row] = ok;
            values[row] = ok ? difference : SequenceOps.Fill;
        }

        return (values, valid);
    }
}
