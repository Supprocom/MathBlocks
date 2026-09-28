
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    /// <summary>Computes the <c>matrix.hadamard-product@1</c> mathematical operation.</summary>
    public static MathBlockMatrix HadamardProduct(MathBlockMatrix left, MathBlockMatrix right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        return Elementwise(left, right, MathBlockScalar.Multiply);
    }
}
