namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.interquartile-range@1</c> mathematical operation.</summary>
    public static float InterquartileRange(IReadOnlyList<float> values) => MathBlockVectorMath.Quantile(values, 0.75f) - MathBlockVectorMath.Quantile(values, 0.25f);
}
