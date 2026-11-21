namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>special.regularized-incomplete-beta@1</c> mathematical operation.</summary>
    public static float RegularizedIncompleteBeta(float x, float left, float right) =>
        RegularizedIncompleteBeta(x, left, right, MathBlockDomainOptions.Default.IncompleteBetaMaximumIterations, MathBlockDomainOptions.Default.IncompleteBetaTolerance, out _);

    // converged is false when the continued fraction used every iteration without reaching the tolerance; the value is then
    // the last estimate.
    internal static float RegularizedIncompleteBeta(
        float x,
        float left,
        float right,
        int maximumIterations,
        float tolerance,
        out bool converged)
    {
        converged = true;
        if (x == 0f)
            return 0f;
        if (x == 1f)
            return 1f;
        var front = Math.Exp(LogGamma(left + right) - LogGamma(left) - LogGamma(right) + left * Math.Log(x) + right * MathBlockScalar.LogOnePlus(-x));
        return x < (left + 1f) / (left + right + 2f)
            ? front * BetaContinuedFraction(x, left, right, maximumIterations, tolerance, out converged) / left
            : 1f - front * BetaContinuedFraction(1f - x, right, left, maximumIterations, tolerance, out converged) / right;
    }
}
