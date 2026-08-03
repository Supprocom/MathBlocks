
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static MathBlockMatrix SchurComplement(MathBlockMatrix matrix, int retainedSize)
    {
        var eliminatedSize = matrix.Rows - retainedSize;
        var leading = new double[retainedSize * retainedSize];
        var upper = new double[retainedSize * eliminatedSize];
        var lower = new double[eliminatedSize * retainedSize];
        var trailing = new double[eliminatedSize * eliminatedSize];
        for (var row = 0; row < matrix.Rows; row++)
        {
            for (var column = 0; column < matrix.Columns; column++)
            {
                if (row < retainedSize && column < retainedSize)
                    leading[row * retainedSize + column] = matrix[row, column];
                else if (row < retainedSize)
                    upper[row * eliminatedSize + column - retainedSize] = matrix[row, column];
                else if (column < retainedSize)
                    lower[(row - retainedSize) * retainedSize + column] = matrix[row, column];
                else
                    trailing[(row - retainedSize) * eliminatedSize + column - retainedSize] = matrix[row, column];
            }
        }

        var trailingMatrix = new MathBlockMatrix(eliminatedSize, eliminatedSize, trailing, true);
        if (!MathBlockLinearAlgebra.TryInverse(trailingMatrix, out var inverse))
            throw new ArithmeticException("The eliminated block is singular.");
        return MathBlockLinearAlgebra.Subtract(new MathBlockMatrix(retainedSize, retainedSize, leading, true), MathBlockLinearAlgebra.Multiply(MathBlockLinearAlgebra.Multiply(new MathBlockMatrix(retainedSize, eliminatedSize, upper, true), inverse!), new MathBlockMatrix(eliminatedSize, retainedSize, lower, true)));
    }
}
