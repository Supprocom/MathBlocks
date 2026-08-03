
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    public static MathBlockMatrix AppendRow(MathBlockMatrix matrix, IReadOnlyList<double> row)
    {
        var result = new double[(matrix.Rows + 1) * matrix.Columns];
        for (var rowIndex = 0; rowIndex < matrix.Rows; rowIndex++)
            for (var column = 0; column < matrix.Columns; column++)
                result[rowIndex * matrix.Columns + column] = matrix[rowIndex, column];
        for (var column = 0; column < matrix.Columns; column++)
            result[matrix.Rows * matrix.Columns + column] = row[column];
        return new MathBlockMatrix(matrix.Rows + 1, matrix.Columns, result, true);
    }
}
