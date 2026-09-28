
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>matrix.integer-power@1</c> mathematical operation.</summary>
    public static MathBlockMatrix MatrixPower(MathBlockMatrix matrix, int exponent)
    {
        ArgumentNullException.ThrowIfNull(matrix);
        var result = MathBlockLinearAlgebra.Identity(matrix.Rows);
        var power = matrix;
        while (exponent > 0)
        {
            if ((exponent & 1) != 0)
                result = MathBlockLinearAlgebra.Multiply(result, power);
            exponent >>= 1;
            if (exponent > 0)
                power = MathBlockLinearAlgebra.Multiply(power, power);
        }

        return result;
    }
}
