namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] RollingMinimum(IReadOnlyList<double> values, int width) => RollingExtreme(values, width, minimum: true);
}
