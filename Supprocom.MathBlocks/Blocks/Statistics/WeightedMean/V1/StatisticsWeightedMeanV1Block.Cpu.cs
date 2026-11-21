namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.weighted-mean@1</c> mathematical operation.</summary>
    public static float WeightedMean(IReadOnlyList<float> values, IReadOnlyList<float> weights) => MathBlockVectorMath.Dot(values, weights) / MathBlockVectorMath.Sum(weights);
}
