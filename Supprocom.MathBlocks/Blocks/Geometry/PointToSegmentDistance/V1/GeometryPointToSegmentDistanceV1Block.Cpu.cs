namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    public static double PointToSegmentDistance(MathBlockPoint point, MathBlockPoint start, MathBlockPoint end)
    {
        var x = end.X - start.X;
        var y = end.Y - start.Y;
        var lengthSquare = x * x + y * y;
        if (lengthSquare == 0d)
            return Distance(point, start);
        var projection = ((point.X - start.X) * x + (point.Y - start.Y) * y) / lengthSquare;
        projection = Math.Clamp(projection, 0d, 1d);
        return Distance(point, new MathBlockPoint(start.X + projection * x, start.Y + projection * y));
    }
}
