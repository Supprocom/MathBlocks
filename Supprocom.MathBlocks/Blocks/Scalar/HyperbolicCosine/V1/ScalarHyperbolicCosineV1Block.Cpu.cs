namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    public static double HyperbolicCosine(double value)
    {
        var positive = DeterministicExponential(value);
        var negative = DeterministicExponential(-value);
        return (positive + negative) / 2d;
    }
}
