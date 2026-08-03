
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    public static bool IsPositiveDefinite(MathBlockMatrix matrix)
    {
        if (!IsSymmetric(matrix))
            return false;
        var size = matrix.Rows;
        var lower = new double[size * size];
        for (var row = 0; row < size; row++)
        {
            for (var column = 0; column <= row; column++)
            {
                var sum = matrix[row, column];
                for (var inner = 0; inner < column; inner++)
                    sum -= lower[row * size + inner] * lower[column * size + inner];
                if (row == column)
                {
                    if (sum <= 0d)
                        return false;
                    lower[row * size + column] = Math.Sqrt(sum);
                }
                else
                {
                    lower[row * size + column] = sum / lower[column * size + column];
                }
            }
        }

        return true;
    }
}
