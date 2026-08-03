namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double Median(IReadOnlyList<double> values) => Quantile(values, 0.5d);
}
