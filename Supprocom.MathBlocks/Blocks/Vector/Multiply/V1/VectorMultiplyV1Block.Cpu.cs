namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Multiply(IReadOnlyList<double> left, IReadOnlyList<double> right) => Zip(left, right, MathBlockScalar.Multiply);
}
