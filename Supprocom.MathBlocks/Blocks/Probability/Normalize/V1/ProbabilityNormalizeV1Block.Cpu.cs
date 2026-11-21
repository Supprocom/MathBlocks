namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>probability.normalize@1</c> mathematical operation.</summary>
    public static float[] Normalize(IReadOnlyList<float> weights)
    {
        var total = MathBlockVectorMath.Sum(weights);
        return MathBlockVectorMath.Scale(weights, 1f / total);
    }
}
