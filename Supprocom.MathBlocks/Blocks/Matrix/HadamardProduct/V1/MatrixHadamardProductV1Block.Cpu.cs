
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    public static MathBlockMatrix HadamardProduct(MathBlockMatrix left, MathBlockMatrix right) => Elementwise(left, right, MathBlockScalar.Multiply);
}
