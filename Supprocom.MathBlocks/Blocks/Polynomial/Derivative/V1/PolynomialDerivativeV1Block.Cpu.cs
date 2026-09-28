
namespace Supprocom.MathBlocks;

public static partial class MathBlockPolynomial
{
    /// <summary>Computes the <c>polynomial.derivative@1</c> mathematical operation.</summary>
    public static double[] Derivative(IReadOnlyList<double> coefficients)
    {
        ArgumentNullException.ThrowIfNull(coefficients);
        if (coefficients.Count <= 1)
            return [0d];
        var result = new double[coefficients.Count - 1];
        for (var index = 1; index < coefficients.Count; index++)
            result[index - 1] = index * coefficients[index];
        return result;
    }
}
