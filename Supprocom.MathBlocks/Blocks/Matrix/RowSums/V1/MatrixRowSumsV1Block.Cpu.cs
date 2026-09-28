
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    /// <summary>Computes the <c>matrix.row-sums@1</c> mathematical operation.</summary>
    public static double[] RowSums(MathBlockMatrix matrix)
    {
        ArgumentNullException.ThrowIfNull(matrix);
        var result = new double[matrix.Rows];
        for (var row = 0; row < matrix.Rows; row++)
            for (var column = 0; column < matrix.Columns; column++)
                result[row] += matrix[row, column];
        return result;
    }
}
