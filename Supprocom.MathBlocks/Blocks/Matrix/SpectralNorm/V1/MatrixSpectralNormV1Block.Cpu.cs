
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>matrix.spectral-norm@1</c> mathematical operation.</summary>
    /// <returns>
    /// The largest singular value, or <see cref="double.NaN"/> when a square in the Gram matrix overflows, so that
    /// the eigenvalue step never sees a non-finite entry (as <c>vector.l2-norm</c> and <c>matrix.frobenius-norm</c>
    /// give an invalid value when their sum of squares overflows).
    /// </returns>
    public static double SpectralNorm(MathBlockMatrix matrix, int _) => SpectralNorm(matrix, MathBlockDomainContext.Default, out bool _);

    // The spectral norm under the context's Jacobi options. nonconverged is true under the Invalid policy when Jacobi stopped at
    // its budget, and the result is then NaN.
    internal static double SpectralNorm(MathBlockMatrix matrix, MathBlockDomainContext domain, out bool nonconverged)
    {
        nonconverged = false;
        var gram = MathBlockLinearAlgebra.Gram(matrix);
        for (var row = 0; row < gram.Rows; row++)
        {
            for (var column = 0; column < gram.Columns; column++)
            {
                if (!double.IsFinite(gram[row, column]))
                {
                    return double.NaN;
                }
            }
        }

        var eigenvalues = MathBlockLinearAlgebra.SymmetricEigenvalues(gram, domain);
        if (eigenvalues is null)
        {
            nonconverged = true;
            return double.NaN;
        }

        return Math.Sqrt(Math.Max(0d, eigenvalues[^1]));
    }
}
