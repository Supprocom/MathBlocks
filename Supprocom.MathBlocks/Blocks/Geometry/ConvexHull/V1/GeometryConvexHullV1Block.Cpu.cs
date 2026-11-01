namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    /// <summary>Computes the <c>geometry.convex-hull@1</c> mathematical operation.</summary>
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
            while (count >= 2 && IsNotLeftTurn(hull[count - 2], hull[count - 1], sorted[index]))
                count--;
            hull[count++] = sorted[index];
        }

        var lowerCount = count;
        for (var index = sorted.Length - 2; index >= 0; index--)
        {
            while (count > lowerCount && IsNotLeftTurn(hull[count - 2], hull[count - 1], sorted[index]))
                count--;
            hull[count++] = sorted[index];
        }

        return hull[..(count - 1)];
    }

    // A NaN cross product (inf - inf from overflowing products) fails the test and would keep a point that may not be on the hull.
    private static bool IsNotLeftTurn(MathBlockPoint origin, MathBlockPoint left, MathBlockPoint right)
    {
        var cross = Cross(origin, left, right);
        if (Math.IsNaN(cross))
            throw new OverflowException("A cross product of the hull construction overflowed.");
        return cross <= 0d;
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
