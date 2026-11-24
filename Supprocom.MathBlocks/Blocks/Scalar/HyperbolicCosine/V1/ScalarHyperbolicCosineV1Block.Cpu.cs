namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.hyperbolic-cosine@1</c> mathematical operation.</summary>
    public static float HyperbolicCosine(float value)
    {
        var positive = DeterministicExponential(value);
        var negative = DeterministicExponential(-value);
        var result = (positive + negative) / 2f;
        // exp overflows above 88.72 while cosh is finite up to 89.415: where the formula overflowed, take (h / 2) * h with h = exp(|x| / 2).
        // Both are computed for every row (a select, no early exit); beyond 89.415 the alternative overflows too and the row is invalid.
        var halfExponential = DeterministicExponential(Math.Abs(value) * 0.5f);
        var alternative = (halfExponential * 0.5f) * halfExponential;
        return float.IsInfinity(result) ? alternative : result;
    }
}
