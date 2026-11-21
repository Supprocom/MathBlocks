namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    /// <summary>Computes the <c>geometry.centroid@1</c> mathematical operation.</summary>
    public static MathBlockPoint Centroid(IReadOnlyList<MathBlockPoint> points)
    {
        ArgumentNullException.ThrowIfNull(points);
        var x = 0f;
        var y = 0f;
        for (var index = 0; index < points.Count; index++)
        {
            x += points[index].X;
            y += points[index].Y;
        }

        return new MathBlockPoint(x / points.Count, y / points.Count);
    }
}
