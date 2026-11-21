namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.power@1</c> mathematical operation.</summary>
    public static float[] Power(IReadOnlyList<float> values, float exponent)
    {
        ArgumentNullException.ThrowIfNull(values);
        return Map(values, value => MathBlockScalar.Power(value, exponent));
    }
}
