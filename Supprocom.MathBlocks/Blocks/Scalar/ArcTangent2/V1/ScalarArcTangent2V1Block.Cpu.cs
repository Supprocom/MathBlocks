namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    public static double ArcTangent2(double y, double x)
    {
        if (x > 0d)
            return DeterministicArcTangent(y / x);
        if (x < 0d)
            return y >= 0d ? DeterministicArcTangent(y / x) + Math.PI : DeterministicArcTangent(y / x) - Math.PI;
        if (y > 0d)
            return Math.PI / 2d;
        if (y < 0d)
            return -Math.PI / 2d;
        return 0d;
    }
}
