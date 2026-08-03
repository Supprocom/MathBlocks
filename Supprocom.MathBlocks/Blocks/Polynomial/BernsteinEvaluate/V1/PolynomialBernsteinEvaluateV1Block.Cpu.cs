
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double BernsteinEvaluate(IReadOnlyList<double> coefficients, double parameter)
    {
        var degree = coefficients.Count - 1;
        var result = 0d;
        for (var index = 0; index <= degree; index++)
            result += coefficients[index] * MathBlockProbability.BinomialCoefficient(degree, index) * Math.Pow(parameter, index) * Math.Pow(1d - parameter, degree - index);
        return result;
    }
}
