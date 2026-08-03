namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Sign(IReadOnlyList<double> values) => Map(values, value => Math.Sign(value));
}
