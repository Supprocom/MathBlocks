namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.sample-covariance@1</c> mathematical operation.</summary>
    public static float SampleCovariance(IReadOnlyList<float> left, IReadOnlyList<float> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        return PopulationCovariance(left, right) * left.Count / (left.Count - 1f);
    }
}
