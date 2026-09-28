
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>matrix.spectral-norm@1</c> mathematical operation.</summary>
    public static double SpectralNorm(MathBlockMatrix matrix, int _)
    {
        var gram = MathBlockLinearAlgebra.Gram(matrix);
        return Math.Sqrt(Math.Max(0d, MathBlockLinearAlgebra.SymmetricEigenvalues(gram)[^1]));
    }
}
