
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    public static bool TrySolve(MathBlockMatrix matrix, IReadOnlyList<double> right, out double[] solution)
    {
        var size = matrix.Rows;
        var augmented = new double[size * (size + 1)];
        for (var row = 0; row < size; row++)
        {
            for (var column = 0; column < size; column++)
                augmented[row * (size + 1) + column] = matrix[row, column];
            augmented[row * (size + 1) + size] = right[row];
        }

        for (var pivot = 0; pivot < size; pivot++)
        {
            var pivotRow = pivot;
            for (var row = pivot + 1; row < size; row++)
                if (Math.Abs(augmented[row * (size + 1) + pivot]) > Math.Abs(augmented[pivotRow * (size + 1) + pivot]))
                    pivotRow = row;
            if (augmented[pivotRow * (size + 1) + pivot] == 0d)
            {
                solution = [];
                return false;
            }

            if (pivotRow != pivot)
                SwapRows(augmented, size + 1, pivot, pivotRow);
            var diagonal = augmented[pivot * (size + 1) + pivot];
            for (var column = pivot; column <= size; column++)
                augmented[pivot * (size + 1) + column] /= diagonal;
            for (var row = 0; row < size; row++)
            {
                if (row == pivot)
                    continue;
                var scale = augmented[row * (size + 1) + pivot];
                for (var column = pivot; column <= size; column++)
                    augmented[row * (size + 1) + column] -= scale * augmented[pivot * (size + 1) + column];
            }
        }

        solution = new double[size];
        for (var row = 0; row < size; row++)
            solution[row] = augmented[row * (size + 1) + size];
        return MathBlockCollectionPrimitives.All(solution, Math.IsFinite);
    }
}
