
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    public static int Rank(MathBlockMatrix matrix)
    {
        var values = matrix.ToArray();
        var rank = 0;
        var pivotColumn = 0;
        while (rank < matrix.Rows && pivotColumn < matrix.Columns)
        {
            var pivotRow = rank;
            for (var row = rank + 1; row < matrix.Rows; row++)
                if (Math.Abs(values[row * matrix.Columns + pivotColumn]) > Math.Abs(values[pivotRow * matrix.Columns + pivotColumn]))
                    pivotRow = row;
            if (values[pivotRow * matrix.Columns + pivotColumn] == 0d)
            {
                pivotColumn++;
                continue;
            }

            SwapRows(values, matrix.Columns, rank, pivotRow);
            var pivot = values[rank * matrix.Columns + pivotColumn];
            for (var row = rank + 1; row < matrix.Rows; row++)
            {
                var scale = values[row * matrix.Columns + pivotColumn] / pivot;
                for (var column = pivotColumn; column < matrix.Columns; column++)
                    values[row * matrix.Columns + column] -= scale * values[rank * matrix.Columns + column];
            }

            rank++;
            pivotColumn++;
        }

        return rank;
    }
}
