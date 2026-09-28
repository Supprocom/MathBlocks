namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    /// <summary>Computes the <c>geometry.path-length@1</c> mathematical operation.</summary>
    public static double PathLength(IReadOnlyList<MathBlockPoint> path)
    {
        ArgumentNullException.ThrowIfNull(path);
        var result = 0d;
        for (var index = 1; index < path.Count; index++)
            result += Distance(path[index - 1], path[index]);
        return result;
    }
}
