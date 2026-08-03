
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double[] MaximalMinors(MathBlockMatrix matrix)
    {
        var result = new List<double>();
        var rows = MathBlockCollectionPrimitives.Range(matrix.Rows);
        foreach (var columns in Combinations(matrix.Columns, matrix.Rows))
            result.Add(MathBlockLinearAlgebra.Determinant(Submatrix(matrix, rows, columns)));
        return MathBlockCollectionPrimitives.Copy(result);
    }
}
