
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>polynomial.bernstein-evaluate@1</c> mathematical operation.</summary>
    public static float BernsteinEvaluate(IReadOnlyList<float> coefficients, float parameter)
    {
        ArgumentNullException.ThrowIfNull(coefficients);
        var degree = coefficients.Count - 1;
        var result = 0f;
        for (var index = 0; index <= degree; index++)
            result += coefficients[index] * MathBlockProbability.BinomialCoefficient(degree, index) * Math.Pow(parameter, index) * Math.Pow(1f - parameter, degree - index);
        return result;
    }
}
