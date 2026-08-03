namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double LogGamma(double value)
    {
        if (value < 0.5d)
            return Math.Log(Math.PI) - Math.Log(Math.Sin(Math.PI * value)) - LogGamma(1d - value);
        value -= 1d;
        var sum = 0.99999999999980993d;
        for (var index = 0; index < lanczosCoefficients.Length; index++)
            sum += lanczosCoefficients[index] / (value + index + 1d);
        var t = value + lanczosCoefficients.Length - 0.5d;
        return 0.5d * Math.Log(2d * Math.PI) + (value + 0.5d) * Math.Log(t) - t + Math.Log(sum);
    }
}
