
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    public static double[] Diagonal(MathBlockMatrix matrix)
    {
        var length = Math.Min(matrix.Rows, matrix.Columns);
        var result = new double[length];
        for (var index = 0; index < length; index++)
            result[index] = matrix[index, index];
        return result;
    }
}
