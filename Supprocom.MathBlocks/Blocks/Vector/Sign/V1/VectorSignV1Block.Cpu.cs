namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.sign@1</c> mathematical operation.</summary>
    public static double[] Sign(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        return Map(values, value => Math.Sign(value));
    }
}
