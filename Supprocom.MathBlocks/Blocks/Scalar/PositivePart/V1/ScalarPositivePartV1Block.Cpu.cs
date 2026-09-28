namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.positive-part@1</c> mathematical operation.</summary>
    public static double PositivePart(double value) => Math.Max(value, 0d);
}
