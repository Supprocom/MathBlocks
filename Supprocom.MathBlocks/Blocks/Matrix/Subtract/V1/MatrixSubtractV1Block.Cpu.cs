
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    public static MathBlockMatrix Subtract(MathBlockMatrix left, MathBlockMatrix right) => Elementwise(left, right, MathBlockScalar.Subtract);
}
