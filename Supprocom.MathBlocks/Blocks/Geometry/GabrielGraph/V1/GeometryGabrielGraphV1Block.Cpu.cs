
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static MathBlockGraph GabrielGraph(IReadOnlyList<MathBlockPoint> points)
    {
        var edges = new List<MathBlockGraphEdge>();
        for (var left = 0; left < points.Count; left++)
        {
            for (var right = left + 1; right < points.Count; right++)
            {
                var center = new MathBlockPoint((points[left].X + points[right].X) / 2d, (points[left].Y + points[right].Y) / 2d);
                var radius = MathBlockGeometry.Distance(points[left], points[right]) / 2d;
                var empty = true;
                for (var index = 0; index < points.Count; index++)
                {
                    if (index != left && index != right && MathBlockGeometry.Distance(points[index], center) < radius)
                    {
                        empty = false;
                        break;
                    }
                }

                if (empty)
                    edges.Add(new MathBlockGraphEdge(left, right, 2d * radius));
            }
        }

        return new MathBlockGraph(points.Count, edges);
    }
}
