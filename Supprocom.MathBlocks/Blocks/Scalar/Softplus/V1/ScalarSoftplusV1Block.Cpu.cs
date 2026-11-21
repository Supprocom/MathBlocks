namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.softplus@1</c> mathematical operation.</summary>
    public static float Softplus(float value) => Math.Max(value, 0f) + LogOnePlus(DeterministicExponential(-Math.Abs(value)));
}
