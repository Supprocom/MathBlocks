namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double[] Normalize(IReadOnlyList<double> weights)
    {
        var total = MathBlockVectorMath.Sum(weights);
        return MathBlockVectorMath.Scale(weights, 1d / total);
    }
}
