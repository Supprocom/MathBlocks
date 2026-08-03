
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    public static MathBlockMatrix Add(MathBlockMatrix left, MathBlockMatrix right) => Elementwise(left, right, MathBlockScalar.Add);
}
