namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] RollingMean(IReadOnlyList<double> values, int width) => Scale(RollingSum(values, width), 1d / width);
}
