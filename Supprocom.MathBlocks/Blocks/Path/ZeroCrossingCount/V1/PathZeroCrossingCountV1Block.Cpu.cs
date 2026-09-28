
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    /// <summary>Computes the <c>path.zero-crossing-count@1</c> mathematical operation.</summary>
    public static int ZeroCrossingCount(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
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
