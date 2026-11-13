namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class MatrixExponentialV1Block
    {
        internal const string Identity = "matrix.exponential@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateMatrixExponential();
        private static MathBlockOperation CreateMatrixExponential() => MathBlockOperationFactory.CreateDomain("matrix.exponential", 1, types =>
        {
            RequireSquareMatrix(types[0]);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            return types[0];
        }, (inputs, domain) => MathBlockValue.Matrix(MathBlockAdvanced.MatrixExponential(inputs[0].AsMatrix(), domain.Options.MatrixExponentialTaylorTerms)), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0d, 0d, 0d, Math.Log(2d)]))], MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1d, 0d, 0d, 2d])), 1e-8, 2);
    }
}
