
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    public static MathBlockMatrix KroneckerProduct(MathBlockMatrix left, MathBlockMatrix right)
    {
        var rows = left.Rows * right.Rows;
        var columns = left.Columns * right.Columns;
        var result = new double[rows * columns];
        for (var leftRow = 0; leftRow < left.Rows; leftRow++)
        {
            for (var leftColumn = 0; leftColumn < left.Columns; leftColumn++)
            {
                for (var rightRow = 0; rightRow < right.Rows; rightRow++)
                {
                    for (var rightColumn = 0; rightColumn < right.Columns; rightColumn++)
                    {
                        var row = leftRow * right.Rows + rightRow;
                        var column = leftColumn * right.Columns + rightColumn;
                        result[row * columns + column] = left[leftRow, leftColumn] * right[rightRow, rightColumn];
                    }
                }
            }
        }

        return new MathBlockMatrix(rows, columns, result, true);
    }
}
