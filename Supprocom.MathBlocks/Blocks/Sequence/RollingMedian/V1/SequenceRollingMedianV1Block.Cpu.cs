namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>sequence.rolling-median@1</c> mathematical operation.</summary>
    public static double[] RollingMedian(IReadOnlyList<double> values, int width) => RollingQuantile(values, width, 0.5d);
}
