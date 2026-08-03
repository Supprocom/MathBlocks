namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double Product(IReadOnlyList<double> values)
    {
        var product = 1d;
        for (var index = 0; index < values.Count; index++)
            product *= values[index];
        return product;
    }
}
