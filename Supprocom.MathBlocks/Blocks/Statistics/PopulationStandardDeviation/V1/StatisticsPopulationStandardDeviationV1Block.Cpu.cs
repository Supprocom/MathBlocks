namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.population-standard-deviation@1</c> mathematical operation.</summary>
    public static double PopulationStandardDeviation(IReadOnlyList<double> values) => Math.Sqrt(PopulationVariance(values));
}
