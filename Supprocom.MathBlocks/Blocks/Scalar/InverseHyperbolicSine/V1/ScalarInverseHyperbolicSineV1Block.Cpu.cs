namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.inverse-hyperbolic-sine@1</c> mathematical operation.</summary>
    public static float InverseHyperbolicSine(float value)
    {
        if (value == 0f)
            return value;
        var magnitude = Math.Abs(value);
        return Math.CopySign(DeterministicNaturalLogarithm(magnitude + Math.Sqrt(magnitude * magnitude + 1f)), value);
    }
}
