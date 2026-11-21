namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>sequence.rolling-maximum@1</c> mathematical operation.</summary>
    public static float[] RollingMaximum(IReadOnlyList<float> values, int width)
    {
        ArgumentNullException.ThrowIfNull(values);
        return RollingExtreme(values, width, minimum: false);
    }
}
