namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    public static double PathLength(IReadOnlyList<MathBlockPoint> path)
    {
        var result = 0d;
        for (var index = 1; index < path.Count; index++)
            result += Distance(path[index - 1], path[index]);
        return result;
    }
}
