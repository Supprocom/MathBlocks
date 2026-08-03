
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double SpectralNorm(MathBlockMatrix matrix, int _)
    {
        var gram = MathBlockLinearAlgebra.Gram(matrix);
        return Math.Sqrt(Math.Max(0d, MathBlockLinearAlgebra.SymmetricEigenvalues(gram)[^1]));
    }
}
