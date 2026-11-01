
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>matrix.exponential@1</c> mathematical operation.</summary>
    public static MathBlockMatrix MatrixExponential(MathBlockMatrix matrix)
    {
        ArgumentNullException.ThrowIfNull(matrix);
        var norm = 0d;
        for (var row = 0; row < matrix.Rows; row++)
        {
            var rowSum = 0d;
            for (var column = 0; column < matrix.Columns; column++)
                rowSum += Math.Abs(matrix[row, column]);
            norm = Math.Max(norm, rowSum);
        }

        // An overflowing norm would ask for int.MaxValue squarings. The result is then not finite, as for any
        // overflow in the series or the squarings.
        if (!double.IsFinite(norm))
            return new MathBlockMatrix(matrix.Rows, matrix.Columns, MathBlockCollectionPrimitives.Repeat(double.NaN, matrix.Rows * matrix.Columns), true);
        // exp(A) overflows when trace(A) / n > ln(DBL_MAX) + ln(n) / 2: det(exp A) = exp(trace A), and by Hadamard |det M| <= (sqrt(n) * max|m_ij|)^n,
        // so some entry of exp(A) exceeds exp(trace(A) / n) / sqrt(n). (The bound with ln(n) instead of ln(n) / 2 is also valid and stricter.) The scaling
        // and squaring below can lose such a result to zeros without ever producing a non-finite value.
        var trace = 0d;
        for (var index = 0; index < matrix.Rows; index++)
            trace += matrix[index, index];
        if (trace / matrix.Rows > 709.782712893383973096d + 0.5d * (Math.Log2(matrix.Rows) * 0.693147180559945309417d))
            return new MathBlockMatrix(matrix.Rows, matrix.Columns, MathBlockCollectionPrimitives.Repeat(double.NaN, matrix.Rows * matrix.Columns), true);
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
