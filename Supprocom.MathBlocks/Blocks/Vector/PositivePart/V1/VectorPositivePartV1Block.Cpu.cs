namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] PositivePart(IReadOnlyList<double> values) => Map(values, value => Math.Max(value, 0d));
}
