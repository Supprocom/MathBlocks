namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>polynomial.elementary-symmetric@1</c> mathematical operation.</summary>
    public static float ElementarySymmetricPolynomial(IReadOnlyList<float> values, int order)
    {
        ArgumentNullException.ThrowIfNull(values);
        var coefficients = new float[order + 1];
        coefficients[0] = 1f;
        for (var valueIndex = 0; valueIndex < values.Count; valueIndex++)
            for (var degree = Math.Min(order, valueIndex + 1); degree >= 1; degree--)
                coefficients[degree] += values[valueIndex] * coefficients[degree - 1];
        return coefficients[order];
    }
}
