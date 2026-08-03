
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static MathBlockMatrix MatrixPower(MathBlockMatrix matrix, int exponent)
    {
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
