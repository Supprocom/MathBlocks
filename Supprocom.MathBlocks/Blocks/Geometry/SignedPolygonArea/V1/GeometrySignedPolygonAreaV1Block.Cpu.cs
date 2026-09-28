namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    /// <summary>Computes the <c>geometry.signed-polygon-area@1</c> mathematical operation.</summary>
    public static double SignedPolygonArea(IReadOnlyList<MathBlockPoint> polygon)
    {
        ArgumentNullException.ThrowIfNull(polygon);
        var twiceArea = 0d;
        for (var index = 0; index < polygon.Count; index++)
        {
            var next = (index + 1) % polygon.Count;
            twiceArea += polygon[index].X * polygon[next].Y - polygon[next].X * polygon[index].Y;
        }

        return twiceArea / 2d;
    }
}
