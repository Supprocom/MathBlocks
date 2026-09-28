
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    /// <summary>Computes the <c>path.maximum-decline@1</c> mathematical operation.</summary>
    public static double MaximumDecline(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var maximum = values[0];
        var decline = 0d;
        for (var index = 1; index < values.Count; index++)
        {
            maximum = Math.Max(maximum, values[index]);
            decline = Math.Max(decline, maximum - values[index]);
        }

        return decline;
    }
}
