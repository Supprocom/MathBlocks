
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>matrix.commutator@1</c> mathematical operation.</summary>
    public static MathBlockMatrix MatrixCommutator(MathBlockMatrix left, MathBlockMatrix right) => MathBlockLinearAlgebra.Subtract(MathBlockLinearAlgebra.Multiply(left, right), MathBlockLinearAlgebra.Multiply(right, left));
}
