namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Subtract(IReadOnlyList<double> left, IReadOnlyList<double> right) => Zip(left, right, MathBlockScalar.Subtract);
}
