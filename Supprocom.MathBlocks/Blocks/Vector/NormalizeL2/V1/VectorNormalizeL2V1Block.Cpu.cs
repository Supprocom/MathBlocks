namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.normalize-l2@1</c> mathematical operation.</summary>
    public static float[] NormalizeL2(IReadOnlyList<float> values)
    {
        var norm = L2Norm(values);
        return Scale(values, 1f / norm);
    }
}
