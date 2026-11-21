namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.common-logarithm@1</c> mathematical operation.</summary>
    public static float CommonLogarithm(float value) => DeterministicNaturalLogarithm(value) / 2.30258509299404568402f;
}
