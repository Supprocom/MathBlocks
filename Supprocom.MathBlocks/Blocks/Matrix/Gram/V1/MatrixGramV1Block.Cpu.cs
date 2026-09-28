
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    /// <summary>Computes the <c>matrix.gram@1</c> mathematical operation.</summary>
    public static MathBlockMatrix Gram(MathBlockMatrix matrix) => Multiply(Transpose(matrix), matrix);
}
