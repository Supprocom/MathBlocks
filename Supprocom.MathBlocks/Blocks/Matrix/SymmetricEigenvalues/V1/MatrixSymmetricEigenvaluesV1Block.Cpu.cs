namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixSymmetricEigenvaluesV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateEigenvalues();
        private static MathBlockOperation CreateEigenvalues() => MathBlockOperationFactory.Create("matrix.symmetric-eigenvalues", 1, EigenvaluesType, inputs => MathBlockLinearAlgebra.IsSymmetric(inputs[0].AsMatrix()) ? MathBlockValue.Vector(MathBlockLinearAlgebra.SymmetricEigenvalues(inputs[0].AsMatrix()), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit), "The matrix is not symmetric."), [symmetric], MathBlockValue.Vector([1d, 3d]), 1e-9, 4);
    }
}
