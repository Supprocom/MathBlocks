namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.arc-tangent-2@1</c> mathematical operation.</summary>
    public static float ArcTangent2(float y, float x)
    {
        if (x > 0f)
            return DeterministicArcTangent(y / x);
        if (x < 0f)
            return !float.IsNegative(y) ? DeterministicArcTangent(y / x) + Math.PI : DeterministicArcTangent(y / x) - Math.PI;
        if (y > 0f)
            return Math.PI / 2f;
        if (y < 0f)
            return -Math.PI / 2f;
        // Both are zeros (IEEE 754, C99 Annex F): atan2(±0, +0) = ±0 and atan2(±0, -0) = ±pi.
        return float.IsNegative(x) ? Math.CopySign(Math.PI, y) : y;
    }
}
