namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.sample-variance@1</c> mathematical operation.</summary>
    public static float SampleVariance(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        return PopulationVariance(values) * values.Count / (values.Count - 1f);
    }
}
