namespace Supprocom.MathBlocks;

internal static partial class MatrixMathBlocks
{
    internal static class MatrixSymmetricEigenvaluesV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateEigenvalues();
        private static MathBlockOperation CreateEigenvalues() => MathBlockOperationFactory.CreateDomain("matrix.symmetric-eigenvalues", 1, EigenvaluesType, (inputs, domain) =>
        {
            if (!MathBlockLinearAlgebra.IsSymmetric(inputs[0].AsMatrix()))
                return MathBlockOperationFactory.Invalid(EigenvaluesType, inputs, "The matrix is not symmetric.");
            var eigenvalues = MathBlockLinearAlgebra.SymmetricEigenvalues(inputs[0].AsMatrix(), domain);
            return eigenvalues is null
                ? MathBlockOperationFactory.Invalid(EigenvaluesType, inputs, "The Jacobi iteration did not converge.")
                : MathBlockValue.Vector(eigenvalues, inputs[0].Type.Unit, true);
        }, [symmetric], MathBlockValue.Vector([1d, 3d]), 1e-9, 4);
    }
}
