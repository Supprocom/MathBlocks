namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    public static double PositivePart(double value) => Math.Max(value, 0d);
}
