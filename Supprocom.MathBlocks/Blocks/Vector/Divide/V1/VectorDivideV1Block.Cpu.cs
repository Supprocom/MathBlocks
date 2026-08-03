namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Divide(IReadOnlyList<double> left, IReadOnlyList<double> right) => Zip(left, right, MathBlockScalar.Divide);
}
