
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    public static double DynamicTimeWarpingDistance(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        var previous = MathBlockCollectionPrimitives.Repeat(
            Math.PositiveInfinity,
            right.Count + 1);
        var current = new double[right.Count + 1];
        previous[0] = 0d;
        for (var leftIndex = 0; leftIndex < left.Count; leftIndex++)
        {
            current[0] = Math.PositiveInfinity;
            for (var rightIndex = 0; rightIndex < right.Count; rightIndex++)
            {
                current[rightIndex + 1] = Math.Abs(left[leftIndex] - right[rightIndex]) + Math.Min(previous[rightIndex + 1], Math.Min(current[rightIndex], previous[rightIndex]));
            }

            (previous, current) = (current, previous);
        }

        return previous[^1];
    }
}
