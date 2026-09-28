namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    /// <summary>Computes the <c>geometry.polygon-area@1</c> mathematical operation.</summary>
    public static double PolygonArea(IReadOnlyList<MathBlockPoint> polygon) => Math.Abs(SignedPolygonArea(polygon));
}
