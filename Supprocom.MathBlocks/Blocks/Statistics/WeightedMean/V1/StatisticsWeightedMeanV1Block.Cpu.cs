namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.weighted-mean@1</c> mathematical operation.</summary>
    public static double WeightedMean(IReadOnlyList<double> values, IReadOnlyList<double> weights) => MathBlockVectorMath.Dot(values, weights) / MathBlockVectorMath.Sum(weights);
}
