
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    public static MathBlockMatrix Scale(MathBlockMatrix matrix, double scalar)
    {
        var result = matrix.ToArray();
        for (var index = 0; index < result.Length; index++)
            result[index] *= scalar;
        return new MathBlockMatrix(matrix.Rows, matrix.Columns, result, true);
    }
}
