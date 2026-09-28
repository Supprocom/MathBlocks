
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    /// <summary>Computes the <c>matrix.scale@1</c> mathematical operation.</summary>
    public static MathBlockMatrix Scale(MathBlockMatrix matrix, double scalar)
    {
        ArgumentNullException.ThrowIfNull(matrix);
        var result = matrix.ToArray();
        for (var index = 0; index < result.Length; index++)
            result[index] *= scalar;
        return new MathBlockMatrix(matrix.Rows, matrix.Columns, result, true);
    }
}
