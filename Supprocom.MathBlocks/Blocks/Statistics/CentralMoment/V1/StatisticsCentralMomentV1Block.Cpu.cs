
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>statistics.central-moment@1</c> mathematical operation.</summary>
    public static double CentralMoment(IReadOnlyList<double> values, int order)
    {
        ArgumentNullException.ThrowIfNull(values);
        var mean = MathBlockVectorMath.Mean(values);
        var sum = 0d;
        for (var index = 0; index < values.Count; index++)
            sum += Math.Pow(values[index] - mean, order);
        return sum / values.Count;
    }
}
