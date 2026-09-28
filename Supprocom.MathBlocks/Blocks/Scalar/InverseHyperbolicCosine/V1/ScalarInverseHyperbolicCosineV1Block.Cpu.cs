namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.inverse-hyperbolic-cosine@1</c> mathematical operation.</summary>
    public static double InverseHyperbolicCosine(double value) => DeterministicNaturalLogarithm(value + Math.Sqrt(value * value - 1d));
}
