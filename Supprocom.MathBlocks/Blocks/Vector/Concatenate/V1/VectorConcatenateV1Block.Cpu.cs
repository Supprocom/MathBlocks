namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.concatenate@1</c> mathematical operation.</summary>
    public static double[] Concatenate(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        var result = new double[left.Count + right.Count];
        for (var index = 0; index < left.Count; index++)
            result[index] = left[index];
        for (var index = 0; index < right.Count; index++)
            result[left.Count + index] = right[index];
        return result;
    }
}
