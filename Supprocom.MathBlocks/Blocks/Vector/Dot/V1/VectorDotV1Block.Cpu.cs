namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double Dot(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        var products = new double[left.Count];
        for (var index = 0; index < left.Count; index++)
            products[index] = left[index] * right[index];
        return Sum(products);
    }
}
