
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>matrix.principal-minors@1</c> mathematical operation.</summary>
    public static double[] PrincipalMinors(MathBlockMatrix matrix)
    {
        ArgumentNullException.ThrowIfNull(matrix);
        var result = new double[(1 << matrix.Rows) - 1];
        for (var mask = 1; mask < 1 << matrix.Rows; mask++)
        {
            var indices = MathBlockCollectionPrimitives.SelectedIndices(
                matrix.Rows,
                index => (mask & (1 << index)) != 0);
            result[mask - 1] = MathBlockLinearAlgebra.Determinant(Submatrix(matrix, indices, indices));
        }

        return result;
    }
}
