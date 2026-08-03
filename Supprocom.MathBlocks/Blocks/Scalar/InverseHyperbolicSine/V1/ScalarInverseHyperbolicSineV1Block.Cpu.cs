namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    public static double InverseHyperbolicSine(double value)
    {
        if (value == 0d)
            return value;
        var magnitude = Math.Abs(value);
        return Math.CopySign(DeterministicNaturalLogarithm(magnitude + Math.Sqrt(magnitude * magnitude + 1d)), value);
    }
}
