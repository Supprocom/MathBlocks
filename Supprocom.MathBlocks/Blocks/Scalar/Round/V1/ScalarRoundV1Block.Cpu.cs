namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.round@1</c> mathematical operation.</summary>
    public static float Round(float value) => Math.Round(value, MidpointRounding.ToEven);
}
