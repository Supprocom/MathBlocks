
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    public static MathBlockMatrix Gram(MathBlockMatrix matrix) => Multiply(Transpose(matrix), matrix);
}
