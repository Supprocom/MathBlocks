
namespace Supprocom.MathBlocks;

public static partial class MathBlockPolynomial
{
    /// <summary>Computes the <c>polynomial.derivative@1</c> mathematical operation.</summary>
    public static float[] Derivative(IReadOnlyList<float> coefficients)
    {
        ArgumentNullException.ThrowIfNull(coefficients);
        if (coefficients.Count <= 1)
            return [0f];
        var result = new float[coefficients.Count - 1];
        for (var index = 1; index < coefficients.Count; index++)
            result[index - 1] = index * coefficients[index];
        return result;
    }
}
