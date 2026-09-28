namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.tangent@1</c> mathematical operation.</summary>
    public static double Tangent(double value) => DeterministicSine(value) / DeterministicCosine(value);
}
