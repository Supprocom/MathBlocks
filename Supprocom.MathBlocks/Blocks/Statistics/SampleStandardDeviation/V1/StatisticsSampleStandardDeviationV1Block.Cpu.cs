namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double SampleStandardDeviation(IReadOnlyList<double> values) => Math.Sqrt(SampleVariance(values));
}
