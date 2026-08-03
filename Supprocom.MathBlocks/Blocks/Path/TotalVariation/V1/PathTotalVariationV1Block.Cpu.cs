
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    public static double TotalVariation(IReadOnlyList<double> values)
    {
        var result = 0d;
        for (var index = 1; index < values.Count; index++)
            result += Math.Abs(values[index] - values[index - 1]);
        return result;
    }
}
