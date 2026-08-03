namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    public static double Perimeter(IReadOnlyList<MathBlockPoint> polygon)
    {
        var result = 0d;
        for (var index = 0; index < polygon.Count; index++)
            result += Distance(polygon[index], polygon[(index + 1) % polygon.Count]);
        return result;
    }
}
