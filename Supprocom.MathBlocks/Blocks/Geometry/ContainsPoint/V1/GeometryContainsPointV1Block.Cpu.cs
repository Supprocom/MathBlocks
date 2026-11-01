namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    /// <summary>Computes the <c>geometry.contains-point@1</c> mathematical operation.</summary>
    /// <exception cref="OverflowException">The abscissa where an edge crosses the point's horizontal line is not finite (an overflowing product).</exception>
    public static bool ContainsPoint(IReadOnlyList<MathBlockPoint> polygon, MathBlockPoint point)
    {
        ArgumentNullException.ThrowIfNull(polygon);
        var inside = false;
        for (var current = 0; current < polygon.Count; current++)
        {
            var previous = current == 0 ? polygon.Count - 1 : current - 1;
            var left = polygon[current];
            var right = polygon[previous];
            if (PointToSegmentDistance(point, left, right) == 0d)
                return true;
            if ((left.Y > point.Y) != (right.Y > point.Y))
            {
                // The crossing lies between the edge's end points, so it is finite unless a product overflowed (then a comparison with it is not decided).
                var crossing = (right.X - left.X) * (point.Y - left.Y) / (right.Y - left.Y) + left.X;
                if (!Math.IsFinite(crossing))
                    throw new OverflowException("The crossing of an edge with the point's horizontal line overflowed.");
                if (point.X < crossing)
                    inside = !inside;
            }
        }

        return inside;
    }
}
