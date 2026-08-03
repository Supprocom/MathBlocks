
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    public static double Determinant(MathBlockMatrix matrix)
    {
        var values = matrix.ToArray();
        var size = matrix.Rows;
        var determinant = 1d;
        for (var pivot = 0; pivot < size; pivot++)
        {
            var pivotRow = pivot;
            for (var row = pivot + 1; row < size; row++)
                if (Math.Abs(values[row * size + pivot]) > Math.Abs(values[pivotRow * size + pivot]))
                    pivotRow = row;
            if (values[pivotRow * size + pivot] == 0d)
                return 0d;
            if (pivotRow != pivot)
            {
                SwapRows(values, size, pivot, pivotRow);
                determinant = -determinant;
            }

            var diagonal = values[pivot * size + pivot];
            determinant *= diagonal;
            for (var row = pivot + 1; row < size; row++)
            {
                var scale = values[row * size + pivot] / diagonal;
                for (var column = pivot + 1; column < size; column++)
                    values[row * size + column] -= scale * values[pivot * size + column];
            }
        }

        return determinant;
    }
}
