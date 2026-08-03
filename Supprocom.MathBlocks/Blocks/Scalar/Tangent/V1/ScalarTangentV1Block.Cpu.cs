namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    public static double Tangent(double value) => DeterministicSine(value) / DeterministicCosine(value);
}
