namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.inverse-hyperbolic-cosine@1</c> mathematical operation.</summary>
    public static float InverseHyperbolicCosine(float value) => DeterministicNaturalLogarithm(value + Math.Sqrt(value * value - 1f));
}
