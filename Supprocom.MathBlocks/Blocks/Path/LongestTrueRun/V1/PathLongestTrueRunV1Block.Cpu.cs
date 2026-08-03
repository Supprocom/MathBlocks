
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    public static int LongestTrueRun(IReadOnlyList<bool> values)
    {
        var maximum = 0;
        var current = 0;
        for (var index = 0; index < values.Count; index++)
        {
            current = values[index] ? current + 1 : 0;
            maximum = Math.Max(maximum, current);
        }

        return maximum;
    }
}
