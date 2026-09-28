
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    /// <summary>Computes the <c>matrix.subtract@1</c> mathematical operation.</summary>
    public static MathBlockMatrix Subtract(MathBlockMatrix left, MathBlockMatrix right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        return Elementwise(left, right, MathBlockScalar.Subtract);
    }
}
