
namespace Supprocom.MathBlocks;

public static partial class MathBlockPolynomial
{
    /// <summary>Computes the <c>polynomial.evaluate@1</c> mathematical operation.</summary>
    public static float Evaluate(IReadOnlyList<float> coefficients, float value)
    {
        ArgumentNullException.ThrowIfNull(coefficients);
        var result = 0f;
        for (var index = coefficients.Count - 1; index >= 0; index--)
            result = result * value + coefficients[index];
        return result;
    }
}
