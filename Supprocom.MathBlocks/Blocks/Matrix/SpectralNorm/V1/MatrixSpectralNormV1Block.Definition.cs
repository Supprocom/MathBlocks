namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class MatrixSpectralNormV1Block
    {
        internal const string Identity = "matrix.spectral-norm@1";
        internal static MathBlockOperation Create() => CreateSpectralNorm();
        private static MathBlockOperation CreateSpectralNorm() => MathBlockOperationFactory.Create("matrix.spectral-norm", 2, PerronValueType, inputs => TryInteger(inputs[1].AsScalar(), out var iterations) && iterations > 0 ? MathBlockValue.Scalar(MathBlockAdvanced.SpectralNorm(inputs[0].AsMatrix(), iterations), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Scalar(inputs[0].Type.Unit), "The iteration count is invalid."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [3d, 0d, 0d, 2d])), MathBlockValue.Scalar(32d)], MathBlockValue.Scalar(3d), 1e-8, 2);
    }
}
