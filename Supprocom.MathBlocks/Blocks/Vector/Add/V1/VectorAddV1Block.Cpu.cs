namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Add(IReadOnlyList<double> left, IReadOnlyList<double> right) => Zip(left, right, MathBlockScalar.Add);
}
