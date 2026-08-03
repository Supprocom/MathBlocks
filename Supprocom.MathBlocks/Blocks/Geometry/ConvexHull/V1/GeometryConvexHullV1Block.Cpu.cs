namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    public static MathBlockPoint[] ConvexHull(IReadOnlyList<MathBlockPoint> points)
    {
        var sorted = MathBlockCollectionPrimitives.DistinctSortedCopy(
            points,
            CompareHullPoints,
            (left, right) => left.X == right.X && left.Y == right.Y);
        if (sorted.Length <= 1)
            return sorted;
        var hull = new MathBlockPoint[2 * sorted.Length];
        var count = 0;
        for (var index = 0; index < sorted.Length; index++)
        {
            while (count >= 2 && Cross(hull[count - 2], hull[count - 1], sorted[index]) <= 0d)
                count--;
            hull[count++] = sorted[index];
        }

        var lowerCount = count;
        for (var index = sorted.Length - 2; index >= 0; index--)
        {
            while (count > lowerCount && Cross(hull[count - 2], hull[count - 1], sorted[index]) <= 0d)
                count--;
            hull[count++] = sorted[index];
        }

        return hull[..(count - 1)];
    }

    private static int CompareHullPoints(MathBlockPoint left, MathBlockPoint right)
    {
        if (left.X < right.X)
            return -1;
        if (left.X > right.X)
            return 1;
        return left.Y < right.Y ? -1 : left.Y > right.Y ? 1 : 0;
    }
}
