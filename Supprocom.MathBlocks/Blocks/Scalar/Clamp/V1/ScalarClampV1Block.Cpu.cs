namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.clamp@1</c> mathematical operation.</summary>
    public static double Clamp(double value, double lower, double upper) => Math.Clamp(value, lower, upper);
}
