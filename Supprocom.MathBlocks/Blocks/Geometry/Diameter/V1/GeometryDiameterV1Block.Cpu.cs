namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    /// <summary>Computes the <c>geometry.diameter@1</c> mathematical operation.</summary>
    public static double Diameter(IReadOnlyList<MathBlockPoint> points)
    {
        ArgumentNullException.ThrowIfNull(points);
        var maximum = 0d;
        for (var left = 0; left < points.Count; left++)
            for (var right = left + 1; right < points.Count; right++)
                maximum = Math.Max(maximum, Distance(points[left], points[right]));
        return maximum;
    }
}
