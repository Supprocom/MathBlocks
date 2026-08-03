
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    public static bool TryInverse(MathBlockMatrix matrix, out MathBlockMatrix? inverse)
    {
        var size = matrix.Rows;
        var values = new double[size * size];
        var right = new double[size];
        for (var column = 0; column < size; column++)
        {
            for (var row = 0; row < right.Length; row++)
                right[row] = 0d;
            right[column] = 1d;
            if (!TrySolve(matrix, right, out var solution))
            {
                inverse = null;
                return false;
            }

            for (var row = 0; row < size; row++)
                values[row * size + column] = solution[row];
        }

        inverse = new MathBlockMatrix(size, size, values, true);
        return true;
    }
}
