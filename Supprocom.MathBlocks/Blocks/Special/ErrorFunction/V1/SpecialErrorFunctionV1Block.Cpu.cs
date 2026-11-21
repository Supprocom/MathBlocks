namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>special.error-function@1</c> mathematical operation.</summary>
    public static float ErrorFunction(float value)
    {
        // Odd function: f(-0) = -0 and f(+0) = +0, as IEEE 754 gives it.
        if (value == 0f)
            return value;
        var magnitude = Math.Abs(value);
        var t = 1f / (1f + 0.5f * magnitude);
        var tau = t * DeterministicExponential(-magnitude * magnitude - 1.26551223f + t * (1.00002368f + t * (0.37409196f + t * (0.09678418f + t * (-0.18628806f + t * (0.27886807f + t * (-1.13520398f + t * (1.48851587f + t * (-0.82215223f + t * 0.17087277f)))))))));
        return Math.CopySign(1f - tau, value);
    }
}
