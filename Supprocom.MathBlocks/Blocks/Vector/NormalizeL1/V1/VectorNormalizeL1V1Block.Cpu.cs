namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.normalize-l1@1</c> mathematical operation.</summary>
    public static float[] NormalizeL1(IReadOnlyList<float> values)
    {
        var norm = L1Norm(values);
        return Scale(values, 1f / norm);
    }
}
