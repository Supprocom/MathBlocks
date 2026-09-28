namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Vector Math contract.</summary>
public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>sequence.convolution@1</c> mathematical operation.</summary>
    public static double[] Convolution(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        var result = new double[left.Count + right.Count - 1];
        for (var leftIndex = 0; leftIndex < left.Count; leftIndex++)
            for (var rightIndex = 0; rightIndex < right.Count; rightIndex++)
                result[leftIndex + rightIndex] += left[leftIndex] * right[rightIndex];
        return result;
    }
}
