namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>sequence.rolling-mean@1</c> mathematical operation.</summary>
    public static float[] RollingMean(IReadOnlyList<float> values, int width) => Scale(RollingSum(values, width), 1f / width);
}
