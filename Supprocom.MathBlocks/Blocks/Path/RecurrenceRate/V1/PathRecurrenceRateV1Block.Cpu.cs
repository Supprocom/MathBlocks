
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    public static double RecurrenceRate(IReadOnlyList<double> values, double threshold)
    {
        var recurrent = 0L;
        var total = (long)values.Count * values.Count;
        for (var left = 0; left < values.Count; left++)
            for (var right = 0; right < values.Count; right++)
                if (Math.Abs(values[left] - values[right]) <= threshold)
                    recurrent++;
        return (double)recurrent / total;
    }
}
