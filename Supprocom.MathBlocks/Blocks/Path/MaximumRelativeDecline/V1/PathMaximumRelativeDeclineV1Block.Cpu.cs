
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    public static double MaximumRelativeDecline(IReadOnlyList<double> values)
    {
        var maximum = values[0];
        var decline = 0d;
        for (var index = 1; index < values.Count; index++)
        {
            maximum = Math.Max(maximum, values[index]);
            decline = Math.Max(decline, (maximum - values[index]) / maximum);
        }

        return decline;
    }
}
