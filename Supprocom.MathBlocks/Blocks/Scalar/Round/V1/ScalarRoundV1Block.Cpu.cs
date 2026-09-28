namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.round@1</c> mathematical operation.</summary>
    public static double Round(double value) => Math.Round(value, MidpointRounding.ToEven);
}
