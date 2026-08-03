namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] RollingMedian(IReadOnlyList<double> values, int width) => RollingQuantile(values, width, 0.5d);
}
