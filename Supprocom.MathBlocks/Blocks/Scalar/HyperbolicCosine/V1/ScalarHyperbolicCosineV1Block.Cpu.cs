namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.hyperbolic-cosine@1</c> mathematical operation.</summary>
    public static float HyperbolicCosine(float value)
    {
        var positive = DeterministicExponential(value);
        var negative = DeterministicExponential(-value);
        return (positive + negative) / 2f;
    }
}
