
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static MathBlockMatrix MatrixCommutator(MathBlockMatrix left, MathBlockMatrix right) => MathBlockLinearAlgebra.Subtract(MathBlockLinearAlgebra.Multiply(left, right), MathBlockLinearAlgebra.Multiply(right, left));
}
