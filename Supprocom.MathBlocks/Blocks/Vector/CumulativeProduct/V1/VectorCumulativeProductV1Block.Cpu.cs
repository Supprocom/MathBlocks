namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] CumulativeProduct(IReadOnlyList<double> values)
    {
        var result = new double[values.Count];
        var product = 1d;
        for (var index = 0; index < values.Count; index++)
        {
            product *= values[index];
            result[index] = product;
        }

        return result;
    }
}
