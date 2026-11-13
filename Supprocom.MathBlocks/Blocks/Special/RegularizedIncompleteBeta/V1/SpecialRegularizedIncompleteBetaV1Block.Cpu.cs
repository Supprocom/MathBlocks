namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>special.regularized-incomplete-beta@1</c> mathematical operation.</summary>
    public static double RegularizedIncompleteBeta(double x, double left, double right) =>
        RegularizedIncompleteBeta(x, left, right, MathBlockDomainOptions.Default.IncompleteBetaMaximumIterations, MathBlockDomainOptions.Default.IncompleteBetaTolerance, out _);

    // converged is false when the continued fraction used every iteration without reaching the tolerance; the value is then
    // the last estimate.
    internal static double RegularizedIncompleteBeta(
        double x,
        double left,
        double right,
        int maximumIterations,
        double tolerance,
        out bool converged)
    {
        converged = true;
        if (x == 0d)
            return 0d;
        if (x == 1d)
            return 1d;
        var front = Math.Exp(LogGamma(left + right) - LogGamma(left) - LogGamma(right) + left * Math.Log(x) + right * MathBlockScalar.LogOnePlus(-x));
        return x < (left + 1d) / (left + right + 2d)
            ? front * BetaContinuedFraction(x, left, right, maximumIterations, tolerance, out converged) / left
            : 1d - front * BetaContinuedFraction(1d - x, right, left, maximumIterations, tolerance, out converged) / right;
    }
}
