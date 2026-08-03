namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Exponential(IReadOnlyList<double> values) => Map(values, MathBlockScalar.Exponential);
}
