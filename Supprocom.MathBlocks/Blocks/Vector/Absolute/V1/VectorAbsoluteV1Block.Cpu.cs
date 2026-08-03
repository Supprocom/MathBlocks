namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Absolute(IReadOnlyList<double> values) => Map(values, Math.Abs);
}
