namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.dot@1</c> mathematical operation.</summary>
    public static float Dot(IReadOnlyList<float> left, IReadOnlyList<float> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        var products = new float[left.Count];
        for (var index = 0; index < left.Count; index++)
            products[index] = left[index] * right[index];
        return Sum(products);
    }
}
