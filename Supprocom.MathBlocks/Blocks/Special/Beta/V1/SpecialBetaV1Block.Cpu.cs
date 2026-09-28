namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>special.beta@1</c> mathematical operation.</summary>
    public static double Beta(double left, double right) => Math.Exp(LogGamma(left) + LogGamma(right) - LogGamma(left + right));
}
