namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>probability.normal-cdf@1</c> mathematical operation.</summary>
    public static double NormalCdf(double value) => 0.5d * (1d + MathBlockScalar.ErrorFunction(value / Math.Sqrt(2d)));
}
