namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Concatenate(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        var result = new double[left.Count + right.Count];
        for (var index = 0; index < left.Count; index++)
            result[index] = left[index];
        for (var index = 0; index < right.Count; index++)
            result[left.Count + index] = right[index];
        return result;
    }
}
