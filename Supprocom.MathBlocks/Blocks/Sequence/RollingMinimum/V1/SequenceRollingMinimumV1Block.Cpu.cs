namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>sequence.rolling-minimum@1</c> mathematical operation.</summary>
    public static double[] RollingMinimum(IReadOnlyList<double> values, int width)
    {
        ArgumentNullException.ThrowIfNull(values);
        return RollingExtreme(values, width, minimum: true);
    }
}
