
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static MathBlockMatrix MatrixExponential(MathBlockMatrix matrix)
    {
        var norm = 0d;
        for (var row = 0; row < matrix.Rows; row++)
        {
            var rowSum = 0d;
            for (var column = 0; column < matrix.Columns; column++)
                rowSum += Math.Abs(matrix[row, column]);
            norm = Math.Max(norm, rowSum);
        }

        var scaling = norm > 1d ? Math.Max(0, (int)Math.Ceiling(Math.Log2(norm))) : 0;
        var scaled = MathBlockLinearAlgebra.Scale(matrix, Math.Pow(2d, -scaling));
        var result = MathBlockLinearAlgebra.Identity(matrix.Rows);
        var term = MathBlockLinearAlgebra.Identity(matrix.Rows);
        for (var order = 1; order <= 48; order++)
        {
            term = MathBlockLinearAlgebra.Scale(MathBlockLinearAlgebra.Multiply(term, scaled), 1d / order);
            result = MathBlockLinearAlgebra.Add(result, term);
        }

        for (var iteration = 0; iteration < scaling; iteration++)
            result = MathBlockLinearAlgebra.Multiply(result, result);
        return result;
    }
}
