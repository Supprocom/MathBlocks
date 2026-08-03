namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double Beta(double left, double right) => Math.Exp(LogGamma(left) + LogGamma(right) - LogGamma(left + right));
}
