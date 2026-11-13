namespace Supprocom.MathBlocks;

internal static partial class MatrixMathBlocks
{
    internal static class MatrixIdentityV1Block
    {
        internal const string Identity = "matrix.identity@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateIdentity();
        private static MathBlockOperation CreateIdentity() => MathBlockOperationFactory.CreateDomain("matrix.identity", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Scalar);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            return MathBlockType.Matrix();
        }, (inputs, domain) =>
        {
            var sizeValue = inputs[0].AsScalar();
            var size = (int)sizeValue;
            return sizeValue == Math.Truncate(sizeValue) && size > 0 && size <= domain.Options.MaximumMatrixSize ? MathBlockValue.Matrix(MathBlockLinearAlgebra.Identity(size)) : MathBlockValue.Invalid(MathBlockType.Matrix(), "The matrix size is outside the operation domain.");
        }, [MathBlockValue.Scalar(2d)], MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1d, 0d, 0d, 1d])), performanceIterations: 16);
    }
}
