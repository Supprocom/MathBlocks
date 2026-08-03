
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    public static MathBlockMatrix PointSetToMatrix(IReadOnlyList<MathBlockPoint> points)
    {
        var values = new double[points.Count * 2];
        for (var index = 0; index < points.Count; index++)
        {
            values[2 * index] = points[index].X;
            values[2 * index + 1] = points[index].Y;
        }

        return new MathBlockMatrix(points.Count, 2, values, true);
    }
}
