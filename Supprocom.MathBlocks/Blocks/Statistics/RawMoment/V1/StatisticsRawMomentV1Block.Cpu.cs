
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>statistics.raw-moment@1</c> mathematical operation.</summary>
    public static double RawMoment(IReadOnlyList<double> values, int order)
    {
        ArgumentNullException.ThrowIfNull(values);
        var sum = 0d;
        for (var index = 0; index < values.Count; index++)
            sum += Math.Pow(values[index], order);
        return sum / values.Count;
    }
}
