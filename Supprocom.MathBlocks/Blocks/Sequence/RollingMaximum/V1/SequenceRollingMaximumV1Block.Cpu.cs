namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] RollingMaximum(IReadOnlyList<double> values, int width) => RollingExtreme(values, width, minimum: false);
}
