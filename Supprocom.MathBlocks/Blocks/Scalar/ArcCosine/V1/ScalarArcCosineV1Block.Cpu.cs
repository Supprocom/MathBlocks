namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.arc-cosine@1</c> mathematical operation.</summary>
    public static float ArcCosine(float value) => value is < -1f or > 1f ? Math.NaN : ArcTangent2(SquareRoot((1f - value) * (1f + value)), value);
}
