namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.clamp@1</c> mathematical operation.</summary>
    public static float Clamp(float value, float lower, float upper) => Math.Clamp(value, lower, upper);
}
