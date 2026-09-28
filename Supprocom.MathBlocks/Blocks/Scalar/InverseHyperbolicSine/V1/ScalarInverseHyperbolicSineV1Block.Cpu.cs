namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.inverse-hyperbolic-sine@1</c> mathematical operation.</summary>
    public static double InverseHyperbolicSine(double value)
    {
        if (value == 0d)
            return value;
        var magnitude = Math.Abs(value);
        return Math.CopySign(DeterministicNaturalLogarithm(magnitude + Math.Sqrt(magnitude * magnitude + 1d)), value);
    }
}
