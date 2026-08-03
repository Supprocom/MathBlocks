namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Scale(IReadOnlyList<double> values, double scalar) => Map(values, value => value * scalar);
}
