
namespace Supprocom.MathBlocks;

public static partial class MathBlockPolynomial
{
    /// <summary>Computes the <c>polynomial.evaluate@1</c> mathematical operation.</summary>
    public static double Evaluate(IReadOnlyList<double> coefficients, double value)
    {
        ArgumentNullException.ThrowIfNull(coefficients);
        var result = 0d;
        for (var index = coefficients.Count - 1; index >= 0; index--)
            result = result * value + coefficients[index];
        return result;
    }
}
