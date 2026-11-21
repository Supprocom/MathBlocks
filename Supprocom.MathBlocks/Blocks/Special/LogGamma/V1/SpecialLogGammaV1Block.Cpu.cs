namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>special.log-gamma@1</c> mathematical operation.</summary>
    public static float LogGamma(float value)
    {
        if (value < 0.5f)
            return Math.Log(Math.PI) - Math.Log(Math.Sin(Math.PI * value)) - LogGamma(1f - value);
        value -= 1f;
        var sum = 0.99999999999980993f;
        for (var index = 0; index < lanczosCoefficients.Length; index++)
            sum += lanczosCoefficients[index] / (value + index + 1f);
        var t = value + lanczosCoefficients.Length - 0.5f;
        return 0.5f * Math.Log(2f * Math.PI) + (value + 0.5f) * Math.Log(t) - t + Math.Log(sum);
    }
}
