
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    public static int FirstPassageIndex(IReadOnlyList<double> values, double threshold, bool atOrAbove)
    {
        for (var index = 0; index < values.Count; index++)
            if (atOrAbove ? values[index] >= threshold : values[index] <= threshold)
                return index;
        return -1;
    }
}
