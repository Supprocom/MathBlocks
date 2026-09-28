
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    /// <summary>Computes the <c>path.recurrence-rate@1</c> mathematical operation.</summary>
    public static double RecurrenceRate(IReadOnlyList<double> values, double threshold)
    {
        ArgumentNullException.ThrowIfNull(values);
        var recurrent = 0L;
        var total = (long)values.Count * values.Count;
        for (var left = 0; left < values.Count; left++)
            for (var right = 0; right < values.Count; right++)
                if (Math.Abs(values[left] - values[right]) <= threshold)
                    recurrent++;
        return (double)recurrent / total;
    }
}
