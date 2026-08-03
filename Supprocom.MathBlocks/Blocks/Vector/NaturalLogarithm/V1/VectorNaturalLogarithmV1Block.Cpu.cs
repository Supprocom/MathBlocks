namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] NaturalLogarithm(IReadOnlyList<double> values) => Map(values, MathBlockScalar.NaturalLogarithm);
}
