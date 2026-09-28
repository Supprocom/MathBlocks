namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.sample-standard-deviation@1</c> mathematical operation.</summary>
    public static double SampleStandardDeviation(IReadOnlyList<double> values) => Math.Sqrt(SampleVariance(values));
}
