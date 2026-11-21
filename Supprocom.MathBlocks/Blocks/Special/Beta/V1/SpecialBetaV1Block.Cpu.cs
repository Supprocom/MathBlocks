namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>special.beta@1</c> mathematical operation.</summary>
    public static float Beta(float left, float right) => Math.Exp(LogGamma(left) + LogGamma(right) - LogGamma(left + right));
}
