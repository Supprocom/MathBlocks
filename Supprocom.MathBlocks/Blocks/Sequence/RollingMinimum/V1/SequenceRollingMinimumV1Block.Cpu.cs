namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>sequence.rolling-minimum@1</c> mathematical operation.</summary>
    public static float[] RollingMinimum(IReadOnlyList<float> values, int width)
    {
        ArgumentNullException.ThrowIfNull(values);
        return RollingExtreme(values, width, minimum: true);
    }
}
