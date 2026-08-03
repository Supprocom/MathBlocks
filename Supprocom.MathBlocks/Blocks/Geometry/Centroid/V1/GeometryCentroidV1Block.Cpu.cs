namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    public static MathBlockPoint Centroid(IReadOnlyList<MathBlockPoint> points)
    {
        var x = 0d;
        var y = 0d;
        for (var index = 0; index < points.Count; index++)
        {
            x += points[index].X;
            y += points[index].Y;
        }

        return new MathBlockPoint(x / points.Count, y / points.Count);
    }
}
