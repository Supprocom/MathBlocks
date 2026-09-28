namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.slice@1</c> mathematical operation.</summary>
    public static double[] Slice(IReadOnlyList<double> values, int start, int length)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = new double[length];
        for (var index = 0; index < length; index++)
            result[index] = values[start + index];
        return result;
    }
}
