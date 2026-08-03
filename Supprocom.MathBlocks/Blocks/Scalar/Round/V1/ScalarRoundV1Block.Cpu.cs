namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    public static double Round(double value) => Math.Round(value, MidpointRounding.ToEven);
}
