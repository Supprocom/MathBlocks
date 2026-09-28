
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>matrix.maximal-minors@1</c> mathematical operation.</summary>
    public static double[] MaximalMinors(MathBlockMatrix matrix)
    {
        ArgumentNullException.ThrowIfNull(matrix);
        var result = new List<double>();
        var rows = MathBlockCollectionPrimitives.Range(matrix.Rows);
        foreach (var columns in Combinations(matrix.Columns, matrix.Rows))
            result.Add(MathBlockLinearAlgebra.Determinant(Submatrix(matrix, rows, columns)));
        return MathBlockCollectionPrimitives.Copy(result);
    }
}
