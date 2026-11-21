namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.population-standard-deviation@1</c> mathematical operation.</summary>
    public static float PopulationStandardDeviation(IReadOnlyList<float> values) => Math.Sqrt(PopulationVariance(values));
}
