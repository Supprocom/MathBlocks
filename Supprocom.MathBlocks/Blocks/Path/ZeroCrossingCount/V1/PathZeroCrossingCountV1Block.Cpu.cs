
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    public static int ZeroCrossingCount(IReadOnlyList<double> values)
    {
        var count = 0;
        var previous = 0;
        for (var index = 0; index < values.Count; index++)
        {
            var current = Math.Sign(values[index]);
            if (current == 0)
                continue;
            if (previous != 0 && current != previous)
                count++;
            previous = current;
        }

        return count;
    }
}
