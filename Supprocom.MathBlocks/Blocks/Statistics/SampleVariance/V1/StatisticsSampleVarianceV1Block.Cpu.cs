namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double SampleVariance(IReadOnlyList<double> values) => PopulationVariance(values) * values.Count / (values.Count - 1d);
}
