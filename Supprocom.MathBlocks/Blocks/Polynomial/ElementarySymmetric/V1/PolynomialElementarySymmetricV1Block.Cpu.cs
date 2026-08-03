namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double ElementarySymmetricPolynomial(IReadOnlyList<double> values, int order)
    {
        var coefficients = new double[order + 1];
        coefficients[0] = 1d;
        for (var valueIndex = 0; valueIndex < values.Count; valueIndex++)
            for (var degree = Math.Min(order, valueIndex + 1); degree >= 1; degree--)
                coefficients[degree] += values[valueIndex] * coefficients[degree - 1];
        return coefficients[order];
    }
}
