namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Square(IReadOnlyList<double> values) => Map(values, value => value * value);
}
