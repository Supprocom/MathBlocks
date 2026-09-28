
namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Path contract.</summary>
public static partial class MathBlockPath
{
    /// <summary>Computes the <c>path.cumulative-deviation@1</c> mathematical operation.</summary>
    public static double[] CumulativeDeviation(IReadOnlyList<double> values, double reference)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = new double[values.Count];
        var sum = 0d;
        for (var index = 0; index < values.Count; index++)
        {
            sum += values[index] - reference;
            result[index] = sum;
        }

        return result;
    }
}
