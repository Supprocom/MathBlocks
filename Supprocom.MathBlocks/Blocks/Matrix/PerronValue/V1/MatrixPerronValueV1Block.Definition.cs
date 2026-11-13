namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class MatrixPerronValueV1Block
    {
        internal const string Identity = "matrix.perron-value@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreatePerronValue();
        private static MathBlockOperation CreatePerronValue() => MathBlockOperationFactory.CreateDomain("matrix.perron-value", 2, PerronValueType, (inputs, domain) => IsNonnegative(inputs[0].AsMatrix()) && TryInteger(inputs[1].AsScalar(), out var iterations) && iterations is > 0 && iterations <= domain.Options.MaximumIterationCount ? MathBlockValue.Scalar(MathBlockAdvanced.PerronValue(inputs[0].AsMatrix(), iterations), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Scalar(inputs[0].Type.Unit), "The inputs are outside the operation domain."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1d, 1d, 1d, 1d])), MathBlockValue.Scalar(32d)], MathBlockValue.Scalar(2d), performanceIterations: 2);
    }
}
