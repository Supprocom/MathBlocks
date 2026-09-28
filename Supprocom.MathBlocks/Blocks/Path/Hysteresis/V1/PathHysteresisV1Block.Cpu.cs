
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    /// <summary>Computes the <c>path.hysteresis@1</c> mathematical operation.</summary>
    public static double[] Hysteresis(IReadOnlyList<double> values, double lower, double upper)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = new double[values.Count];
        var state = 0d;
        for (var index = 0; index < values.Count; index++)
        {
            if (values[index] >= upper)
                state = 1d;
            else if (values[index] <= lower)
                state = -1d;
            result[index] = state;
        }

        return result;
    }
}
