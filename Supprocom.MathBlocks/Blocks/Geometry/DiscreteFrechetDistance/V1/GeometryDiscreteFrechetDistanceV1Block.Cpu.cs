namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    public static double DiscreteFrechetDistance(IReadOnlyList<MathBlockPoint> left, IReadOnlyList<MathBlockPoint> right)
    {
        var values = new double[left.Count * right.Count];
        for (var leftIndex = 0; leftIndex < left.Count; leftIndex++)
        {
            for (var rightIndex = 0; rightIndex < right.Count; rightIndex++)
            {
                var distance = Distance(left[leftIndex], right[rightIndex]);
                if (leftIndex == 0 && rightIndex == 0)
                    values[0] = distance;
                else if (leftIndex == 0)
                    values[rightIndex] = Math.Max(values[rightIndex - 1], distance);
                else if (rightIndex == 0)
                    values[leftIndex * right.Count] = Math.Max(values[(leftIndex - 1) * right.Count], distance);
                else
                {
                    var preceding = Math.Min(values[(leftIndex - 1) * right.Count + rightIndex], Math.Min(values[(leftIndex - 1) * right.Count + rightIndex - 1], values[leftIndex * right.Count + rightIndex - 1]));
                    values[leftIndex * right.Count + rightIndex] = Math.Max(preceding, distance);
                }
            }
        }

        return values[^1];
    }
}
