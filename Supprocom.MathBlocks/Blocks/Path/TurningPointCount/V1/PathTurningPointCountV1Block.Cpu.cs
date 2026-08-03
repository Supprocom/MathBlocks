
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    public static int TurningPointCount(IReadOnlyList<double> values)
    {
        var count = 0;
        var previousDirection = 0;
        for (var index = 1; index < values.Count; index++)
        {
            var direction = Math.Sign(values[index] - values[index - 1]);
            if (direction == 0)
                continue;
            if (previousDirection != 0 && direction != previousDirection)
                count++;
            previousDirection = direction;
        }

        return count;
    }
}
