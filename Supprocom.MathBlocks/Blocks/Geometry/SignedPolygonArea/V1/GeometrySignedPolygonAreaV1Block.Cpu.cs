namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    public static double SignedPolygonArea(IReadOnlyList<MathBlockPoint> polygon)
    {
        var twiceArea = 0d;
        for (var index = 0; index < polygon.Count; index++)
        {
            var next = (index + 1) % polygon.Count;
            twiceArea += polygon[index].X * polygon[next].Y - polygon[next].X * polygon[index].Y;
        }

        return twiceArea / 2d;
    }
}
