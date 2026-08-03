namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double WeightedMean(IReadOnlyList<double> values, IReadOnlyList<double> weights) => MathBlockVectorMath.Dot(values, weights) / MathBlockVectorMath.Sum(weights);
}
