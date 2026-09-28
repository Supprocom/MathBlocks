
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    /// <summary>Computes the <c>path.first-passage-index@1</c> mathematical operation.</summary>
    public static int FirstPassageIndex(IReadOnlyList<double> values, double threshold, bool atOrAbove)
    {
        ArgumentNullException.ThrowIfNull(values);
        for (var index = 0; index < values.Count; index++)
            if (atOrAbove ? values[index] >= threshold : values[index] <= threshold)
                return index;
        return -1;
    }
}
