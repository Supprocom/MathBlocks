namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>probability.normalize@1</c> mathematical operation.</summary>
    public static double[] Normalize(IReadOnlyList<double> weights)
    {
        var total = MathBlockVectorMath.Sum(weights);
        return MathBlockVectorMath.Scale(weights, 1d / total);
    }
}
