
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    /// <summary>Computes the <c>matrix.frobenius-norm@1</c> mathematical operation.</summary>
    public static double FrobeniusNorm(MathBlockMatrix matrix)
    {
        ArgumentNullException.ThrowIfNull(matrix);
        var values = matrix.ToArray();
        return MathBlockVectorMath.L2Norm(values);
    }
}
