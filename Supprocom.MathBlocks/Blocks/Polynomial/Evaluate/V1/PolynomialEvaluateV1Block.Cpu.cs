
namespace Supprocom.MathBlocks;

public static partial class MathBlockPolynomial
{
    public static double Evaluate(IReadOnlyList<double> coefficients, double value)
    {
        var result = 0d;
        for (var index = coefficients.Count - 1; index >= 0; index--)
            result = result * value + coefficients[index];
        return result;
    }
}
