namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    /// <summary>Computes the <c>geometry.perimeter@1</c> mathematical operation.</summary>
    public static float Perimeter(IReadOnlyList<MathBlockPoint> polygon)
    {
        ArgumentNullException.ThrowIfNull(polygon);
        var result = 0f;
        for (var index = 0; index < polygon.Count; index++)
            result += Distance(polygon[index], polygon[(index + 1) % polygon.Count]);
        return result;
    }
}
