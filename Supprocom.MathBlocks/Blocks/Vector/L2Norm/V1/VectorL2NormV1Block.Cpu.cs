namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.l2-norm@1</c> mathematical operation.</summary>
    public static double L2Norm(IReadOnlyList<double> values) => Math.Sqrt(Dot(values, values));
}
