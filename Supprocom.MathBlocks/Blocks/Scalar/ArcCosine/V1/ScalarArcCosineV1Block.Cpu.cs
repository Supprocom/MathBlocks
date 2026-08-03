namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    public static double ArcCosine(double value) => value is < -1d or > 1d ? Math.NaN : ArcTangent2(SquareRoot((1d - value) * (1d + value)), value);
}
