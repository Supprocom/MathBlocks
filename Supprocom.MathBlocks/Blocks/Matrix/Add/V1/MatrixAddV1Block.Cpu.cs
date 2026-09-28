
namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Linear Algebra contract.</summary>
public static partial class MathBlockLinearAlgebra
{
    /// <summary>Computes the <c>matrix.add@1</c> mathematical operation.</summary>
    public static MathBlockMatrix Add(MathBlockMatrix left, MathBlockMatrix right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        return Elementwise(left, right, MathBlockScalar.Add);
    }
}
