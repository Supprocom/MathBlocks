
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    public static MathBlockPointSet PointSetFromMatrix(MathBlockMatrix matrix)
    {
        var points = new MathBlockPoint[matrix.Rows];
        for (var row = 0; row < matrix.Rows; row++)
            points[row] = new MathBlockPoint(matrix[row, 0], matrix[row, 1]);
        return new MathBlockPointSet(points, true);
    }
}
