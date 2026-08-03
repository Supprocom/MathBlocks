
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    public static double Trace(MathBlockMatrix matrix)
    {
        var result = 0d;
        for (var index = 0; index < matrix.Rows; index++)
            result += matrix[index, index];
        return result;
    }
}
