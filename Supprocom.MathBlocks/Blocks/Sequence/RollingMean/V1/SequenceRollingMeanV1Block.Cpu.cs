namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>sequence.rolling-mean@1</c> mathematical operation.</summary>
    public static double[] RollingMean(IReadOnlyList<double> values, int width) => Scale(RollingSum(values, width), 1d / width);
}
