
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    public static double[] ColumnSums(MathBlockMatrix matrix)
    {
        var result = new double[matrix.Columns];
        for (var row = 0; row < matrix.Rows; row++)
            for (var column = 0; column < matrix.Columns; column++)
                result[column] += matrix[row, column];
        return result;
    }
}
