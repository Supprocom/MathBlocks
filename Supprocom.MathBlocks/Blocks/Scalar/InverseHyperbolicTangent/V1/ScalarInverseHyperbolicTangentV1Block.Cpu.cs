namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    public static double InverseHyperbolicTangent(double value) => 0.5d * LogOnePlus(2d * value / (1d - value));
}
