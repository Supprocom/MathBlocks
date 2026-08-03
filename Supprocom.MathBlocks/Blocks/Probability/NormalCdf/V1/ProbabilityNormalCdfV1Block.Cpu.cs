namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double NormalCdf(double value) => 0.5d * (1d + MathBlockScalar.ErrorFunction(value / Math.Sqrt(2d)));
}
