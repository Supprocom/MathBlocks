namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    public static double ErrorFunction(double value)
    {
        if (value == 0d)
            return 0d;
        var magnitude = Math.Abs(value);
        var t = 1d / (1d + 0.5d * magnitude);
        var tau = t * DeterministicExponential(-magnitude * magnitude - 1.26551223d + t * (1.00002368d + t * (0.37409196d + t * (0.09678418d + t * (-0.18628806d + t * (0.27886807d + t * (-1.13520398d + t * (1.48851587d + t * (-0.82215223d + t * 0.17087277d)))))))));
        return Math.CopySign(1d - tau, value);
    }
}
