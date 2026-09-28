namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.normalize-l2@1</c> mathematical operation.</summary>
    public static double[] NormalizeL2(IReadOnlyList<double> values)
    {
        var norm = L2Norm(values);
        return Scale(values, 1d / norm);
    }
}
