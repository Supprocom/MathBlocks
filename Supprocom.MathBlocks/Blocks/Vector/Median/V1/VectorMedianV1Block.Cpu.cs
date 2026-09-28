namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.median@1</c> mathematical operation.</summary>
    public static double Median(IReadOnlyList<double> values) => Quantile(values, 0.5d);
}
