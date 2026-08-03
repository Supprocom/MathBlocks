namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double RegularizedIncompleteBeta(double x, double left, double right)
    {
        if (x == 0d)
            return 0d;
        if (x == 1d)
            return 1d;
        var front = Math.Exp(LogGamma(left + right) - LogGamma(left) - LogGamma(right) + left * Math.Log(x) + right * MathBlockScalar.LogOnePlus(-x));
        return x < (left + 1d) / (left + right + 2d) ? front * BetaContinuedFraction(x, left, right) / left : 1d - front * BetaContinuedFraction(1d - x, right, left) / right;
    }
}
