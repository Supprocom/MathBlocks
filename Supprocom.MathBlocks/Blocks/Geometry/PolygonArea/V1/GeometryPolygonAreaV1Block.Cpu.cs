namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    public static double PolygonArea(IReadOnlyList<MathBlockPoint> polygon) => Math.Abs(SignedPolygonArea(polygon));
}
