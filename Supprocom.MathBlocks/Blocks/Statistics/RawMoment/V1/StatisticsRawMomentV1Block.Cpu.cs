
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double RawMoment(IReadOnlyList<double> values, int order)
    {
        var sum = 0d;
        for (var index = 0; index < values.Count; index++)
            sum += Math.Pow(values[index], order);
        return sum / values.Count;
    }
}
