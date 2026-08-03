
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    public static double FrobeniusNorm(MathBlockMatrix matrix)
    {
        var values = matrix.ToArray();
        return MathBlockVectorMath.L2Norm(values);
    }
}
