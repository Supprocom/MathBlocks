namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.arc-tangent-2@1</c> mathematical operation.</summary>
    public static double ArcTangent2(double y, double x)
    {
        if (x > 0d)
            return DeterministicArcTangent(y / x);
        if (x < 0d)
            return !double.IsNegative(y) ? DeterministicArcTangent(y / x) + Math.PI : DeterministicArcTangent(y / x) - Math.PI;
        if (y > 0d)
            return Math.PI / 2d;
        if (y < 0d)
            return -Math.PI / 2d;
        // Both are zeros (IEEE 754, C99 Annex F): atan2(±0, +0) = ±0 and atan2(±0, -0) = ±pi.
        return double.IsNegative(x) ? Math.CopySign(Math.PI, y) : y;
    }
}
