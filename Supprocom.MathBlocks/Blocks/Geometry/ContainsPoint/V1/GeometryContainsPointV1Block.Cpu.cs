namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    public static bool ContainsPoint(IReadOnlyList<MathBlockPoint> polygon, MathBlockPoint point)
    {
        var inside = false;
        for (var current = 0; current < polygon.Count; current++)
        {
            var previous = current == 0 ? polygon.Count - 1 : current - 1;
            var left = polygon[current];
            var right = polygon[previous];
            if (PointToSegmentDistance(point, left, right) == 0d)
                return true;
            if ((left.Y > point.Y) != (right.Y > point.Y) && point.X < (right.X - left.X) * (point.Y - left.Y) / (right.Y - left.Y) + left.X)
            {
                inside = !inside;
            }
        }

        return inside;
    }
}
