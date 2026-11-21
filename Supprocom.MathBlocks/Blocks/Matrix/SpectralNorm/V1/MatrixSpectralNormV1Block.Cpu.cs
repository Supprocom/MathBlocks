
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>matrix.spectral-norm@1</c> mathematical operation.</summary>
    /// <returns>
    /// The largest singular value, or <see cref="double.NaN"/> when a square in the Gram matrix overflows, so that
    /// the eigenvalue step never sees a non-finite entry (as <c>vector.l2-norm</c> and <c>matrix.frobenius-norm</c>
    /// give an invalid value when their sum of squares overflows).
    /// </returns>
    public static float SpectralNorm(MathBlockMatrix matrix, int _) => SpectralNorm(matrix, MathBlockDomainContext.Default, out bool _);

    // The spectral norm under the context's Jacobi options. nonconverged is true under the Invalid policy when Jacobi stopped at
    // its budget, and the result is then NaN.
    internal static float SpectralNorm(MathBlockMatrix matrix, MathBlockDomainContext domain, out bool nonconverged)
    {
        nonconverged = false;
        var gram = MathBlockLinearAlgebra.Gram(matrix);
        for (var row = 0; row < gram.Rows; row++)
        {
            for (var column = 0; column < gram.Columns; column++)
            {
                if (!float.IsFinite(gram[row, column]))
                {
                    return float.NaN;
                }
            }
        }

        var eigenvalues = MathBlockLinearAlgebra.SymmetricEigenvalues(gram, domain);
        if (eigenvalues is null)
        {
            nonconverged = true;
            return float.NaN;
        }

        return Math.Sqrt(Math.Max(0f, eigenvalues[^1]));
    }
}
