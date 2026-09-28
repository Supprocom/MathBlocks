namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.multiply@1</c> mathematical operation.</summary>
    public static double[] Multiply(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        return Zip(left, right, MathBlockScalar.Multiply);
    }
}
