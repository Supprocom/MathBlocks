namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.cumulative-sum@1</c> mathematical operation.</summary>
    public static double[] CumulativeSum(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = new double[values.Count];
        var sum = 0d;
        for (var index = 0; index < values.Count; index++)
        {
            sum += values[index];
            result[index] = sum;
        }

        return result;
    }
}
