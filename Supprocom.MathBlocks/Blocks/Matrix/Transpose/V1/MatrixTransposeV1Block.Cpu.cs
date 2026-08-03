
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    public static MathBlockMatrix Transpose(MathBlockMatrix matrix)
    {
        var result = new double[matrix.Rows * matrix.Columns];
        for (var row = 0; row < matrix.Rows; row++)
            for (var column = 0; column < matrix.Columns; column++)
                result[column * matrix.Rows + row] = matrix[row, column];
        return new MathBlockMatrix(matrix.Columns, matrix.Rows, result, true);
    }
}
