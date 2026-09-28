namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.dot@1</c> mathematical operation.</summary>
    public static double Dot(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        var products = new double[left.Count];
        for (var index = 0; index < left.Count; index++)
            products[index] = left[index] * right[index];
        return Sum(products);
    }
}
