
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>matrix.is-totally-nonnegative@1</c> mathematical operation.</summary>
    public static bool IsTotallyNonnegative(MathBlockMatrix matrix)
    {
        ArgumentNullException.ThrowIfNull(matrix);
        var maximumOrder = Math.Min(matrix.Rows, matrix.Columns);
        for (var order = 1; order <= maximumOrder; order++)
        {
            foreach (var rows in Combinations(matrix.Rows, order))
            {
                foreach (var columns in Combinations(matrix.Columns, order))
                {
                    if (MathBlockLinearAlgebra.Determinant(Submatrix(matrix, rows, columns)) < 0d)
                        return false;
                }
            }
        }

        return true;
    }
}
