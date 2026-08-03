namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Convolution(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        var result = new double[left.Count + right.Count - 1];
        for (var leftIndex = 0; leftIndex < left.Count; leftIndex++)
            for (var rightIndex = 0; rightIndex < right.Count; rightIndex++)
                result[leftIndex + rightIndex] += left[leftIndex] * right[rightIndex];
        return result;
    }
}
