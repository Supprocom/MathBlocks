
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    /// <summary>Computes the <c>matrix.trace@1</c> mathematical operation.</summary>
    public static double Trace(MathBlockMatrix matrix)
    {
        ArgumentNullException.ThrowIfNull(matrix);
        var result = 0d;
        for (var index = 0; index < matrix.Rows; index++)
            result += matrix[index, index];
        return result;
    }
}
