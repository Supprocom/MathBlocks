namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.exponential@1</c> mathematical operation.</summary>
    public static double[] Exponential(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        return Map(values, MathBlockScalar.Exponential);
    }
}
