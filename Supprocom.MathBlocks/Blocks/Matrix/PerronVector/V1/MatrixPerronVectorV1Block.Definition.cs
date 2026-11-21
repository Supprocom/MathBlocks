namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class MatrixPerronVectorV1Block
    {
        internal const string Identity = "matrix.perron-vector@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreatePerronVector();
        private static MathBlockOperation CreatePerronVector() => MathBlockOperationFactory.CreateDomain("matrix.perron-vector", 2, PerronVectorType, (inputs, domain) => IsNonnegative(inputs[0].AsMatrix()) && TryInteger(inputs[1].AsScalar(), out var iterations) && iterations is > 0 && iterations <= domain.Options.MaximumIterationCount ? MathBlockValue.Vector(MathBlockAdvanced.PerronVector(inputs[0].AsMatrix(), iterations), default, true) : MathBlockValue.Invalid(MathBlockType.Vector(length: inputs[0].Type.Rows), "The inputs are outside the operation domain."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1f, 1f, 1f, 1f])), MathBlockValue.Scalar(32f)], MathBlockValue.Vector([0.5f, 0.5f]), performanceIterations: 2);
    }
}
