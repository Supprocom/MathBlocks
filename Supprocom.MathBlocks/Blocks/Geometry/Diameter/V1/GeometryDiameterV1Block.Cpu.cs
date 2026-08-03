namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    public static double Diameter(IReadOnlyList<MathBlockPoint> points)
    {
        var maximum = 0d;
        for (var left = 0; left < points.Count; left++)
            for (var right = left + 1; right < points.Count; right++)
                maximum = Math.Max(maximum, Distance(points[left], points[right]));
        return maximum;
    }
}
