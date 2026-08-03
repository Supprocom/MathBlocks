
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    public static double[] RowSums(MathBlockMatrix matrix)
    {
        var result = new double[matrix.Rows];
        for (var row = 0; row < matrix.Rows; row++)
            for (var column = 0; column < matrix.Columns; column++)
                result[row] += matrix[row, column];
        return result;
    }
}
