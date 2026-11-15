using System.Globalization;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>The six new sequence operations and their -valid siblings: how to find them, how to build their inputs and which parameters PatternResearcher uses.</summary>
internal static class SequenceOps
{
    /// <summary>The fill that unavailable rows get.</summary>
    internal const double Fill = -98_765.25d;

    /// <summary>The offset that first-true-offset gives when nothing matched.</summary>
    internal const double NoMatch = 77d;

    /// <summary>The name of the operation that reads the predicate series.</summary>
    internal const string FirstTrue = "first-true-offset";

    /// <summary>The name of the lag operation, the only one that is labelled Expanding.</summary>
    internal const string Lag = "lag";

    /// <summary>The six operations, without the <c>sequence.</c> prefix.</summary>
    internal static readonly string[] Names =
    [
        "lead", Lag, FirstTrue, "sum-over-offsets", "maximum-over-offsets", "prefix-difference-over-offsets"
    ];

    // PatternResearcher's lag and read offsets at commit 8a61b520 are 0, 1, 2, 4, 8 and 16 (Lag fields), 20 (prediction-frame-count) and up to 96 (LagFrames); its
    // first-true-offset reads offsets 1 to 4 (StartOffset 1, EndOffset 4) and its rolling windows are 3, 6 and 12 frames. The timing sweeps use those values and extend
    // the spans to 256 so that growth along the parameter can be fitted.
    internal static readonly ProofParameter[] ShiftTiming = Shifts([1, 2, 4, 8, 16, 20, 32, 64, 96]);

    internal static readonly ProofParameter[] SpanTiming = Spans([(0, 0), (0, 2), (1, 4), (-5, 0), (-3, 3), (0, 11), (0, 63), (0, 255)]);

    internal static readonly ProofParameter[] ShiftSafety = Shifts([1, 2, 3, 5, 8, 16, 20, 64, 96, 700]);

    internal static readonly ProofParameter[] SpanSafety = Spans(
        [(0, 0), (1, 1), (0, 2), (1, 4), (2, 5), (-5, 0), (-2, -1), (-3, 3), (-1, 1), (3, 3), (5, 9), (-9, -5), (0, 11), (-11, 0), (0, 63), (-95, 0), (0, 255), (-128, 127), (-255, 0), (-700, 700)]);

    internal static readonly ProofParameter[] ShiftDevice = Shifts([1, 3, 20, 96, 1300, 0]);

    internal static readonly ProofParameter[] SpanDevice = [.. Spans([(0, 0), (1, 4), (-3, 3), (0, 11), (-11, 0), (0, 255), (5, 9), (-9, -5), (2, 1)]), new("0.5..1", 0.5d, 1d, 1d)];

    /// <summary>Gets whether the operation takes k instead of start and end.</summary>
    internal static bool IsShift(string name) => string.Equals(name, "lead", StringComparison.Ordinal) || string.Equals(name, Lag, StringComparison.Ordinal);

    /// <summary>Gets the operation or its -valid sibling from the standard catalog.</summary>
    internal static MathBlockOperation Operation(string name, bool sibling) =>
        MathBlockCatalog.Standard.Get(sibling ? string.Concat("sequence.", name, "-valid") : string.Concat("sequence.", name));

    /// <summary>Gets the parameter settings of the operation for a sweep that chose the shift settings or the span settings.</summary>
    internal static ProofParameter[] Parameters(string name, ProofParameter[] shifts, ProofParameter[] spans) => IsShift(name) ? shifts : spans;

    /// <summary>Gets the series that the operation reads: the predicate for first-true-offset, the values for the others.</summary>
    internal static double[] Series(string name, ProofSet set) => string.Equals(name, FirstTrue, StringComparison.Ordinal) ? set.Predicate : set.First;

    /// <summary>
    /// Builds the inputs of the operation: the series, its availability, the counts, k or start and end, and for a value operation the fill (first-true-offset takes
    /// the no-match offset before it). The series, availability and counts arrive as built values so a timing loop builds them once.
    /// </summary>
    internal static MathBlockValue[] Inputs(string name, bool sibling, MathBlockValue series, MathBlockValue availability, MathBlockValue counts, double first, double second)
    {
        var inputs = new List<MathBlockValue> { series, availability, counts, MathBlockValue.Scalar(first) };
        if (!IsShift(name))
            inputs.Add(MathBlockValue.Scalar(second));
        if (!sibling)
        {
            if (string.Equals(name, FirstTrue, StringComparison.Ordinal))
                inputs.Add(MathBlockValue.Scalar(NoMatch));
            inputs.Add(MathBlockValue.Scalar(Fill));
        }

        return [.. inputs];
    }

    private static ProofParameter[] Shifts(int[] values)
    {
        var parameters = new ProofParameter[values.Length];
        for (var index = 0; index < values.Length; index++)
        {
            var label = string.Create(CultureInfo.InvariantCulture, $"k={values[index]}");
            parameters[index] = new ProofParameter(label, values[index], values[index], Math.Max(1d, values[index]));
        }

        return parameters;
    }

    private static ProofParameter[] Spans((int Start, int End)[] values)
    {
        var parameters = new ProofParameter[values.Length];
        for (var index = 0; index < values.Length; index++)
        {
            var (start, end) = values[index];
            var label = string.Create(CultureInfo.InvariantCulture, $"[{start},{end}]");
            parameters[index] = new ProofParameter(label, start, end, Math.Max(1d, (double)end - start + 1d));
        }

        return parameters;
    }
}
