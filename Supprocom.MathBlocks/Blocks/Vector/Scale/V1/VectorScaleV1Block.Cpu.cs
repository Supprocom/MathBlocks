namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.scale@1</c> mathematical operation.</summary>
    public static double[] Scale(IReadOnlyList<double> values, double scalar)
    {
        ArgumentNullException.ThrowIfNull(values);
        return Map(values, value => value * scalar);
    }
}
