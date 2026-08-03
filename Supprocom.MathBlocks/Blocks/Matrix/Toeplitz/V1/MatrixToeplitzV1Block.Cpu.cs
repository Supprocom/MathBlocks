
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static MathBlockMatrix Toeplitz(IReadOnlyList<double> firstColumn, IReadOnlyList<double> firstRow)
    {
        var result = new double[firstColumn.Count * firstRow.Count];
        for (var row = 0; row < firstColumn.Count; row++)
        {
            for (var column = 0; column < firstRow.Count; column++)
                result[row * firstRow.Count + column] = column >= row ? firstRow[column - row] : firstColumn[row - column];
        }

        return new MathBlockMatrix(firstColumn.Count, firstRow.Count, result, true);
    }
}
