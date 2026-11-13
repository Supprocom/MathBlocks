namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class MatrixSpectralNormV1Block
    {
        internal const string Identity = "matrix.spectral-norm@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateSpectralNorm();
        private static MathBlockOperation CreateSpectralNorm() => MathBlockOperationFactory.CreateDomain("matrix.spectral-norm", 2, PerronValueType, Evaluate, [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [3d, 0d, 0d, 2d])), MathBlockValue.Scalar(32d)], MathBlockValue.Scalar(3d), 1e-8, 2);

        private static MathBlockValue Evaluate(IReadOnlyList<MathBlockValue> inputs, MathBlockDomainContext domain)
        {
            var type = MathBlockType.Scalar(inputs[0].Type.Unit);
            if (!TryInteger(inputs[1].AsScalar(), out var iterations) || iterations <= 0 || iterations > domain.Options.MaximumIterationCount)
            {
                return MathBlockValue.Invalid(type, "The iteration count is invalid.");
            }

            var norm = MathBlockAdvanced.SpectralNorm(inputs[0].AsMatrix(), domain, out var nonconverged);
            if (nonconverged)
                return MathBlockValue.Invalid(type, "The Jacobi iteration did not converge.");
            return double.IsFinite(norm) ? MathBlockValue.Scalar(norm, inputs[0].Type.Unit) : MathBlockValue.Invalid(type, "The squared entries overflow.");
        }
    }
}
