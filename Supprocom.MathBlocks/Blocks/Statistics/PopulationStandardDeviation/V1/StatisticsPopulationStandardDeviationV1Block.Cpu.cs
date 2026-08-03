namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double PopulationStandardDeviation(IReadOnlyList<double> values) => Math.Sqrt(PopulationVariance(values));
}
