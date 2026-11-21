namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class SequenceRollingQuantileV1Block
    {
        internal const string Identity = "sequence.rolling-quantile@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Trailing(1);
        internal static MathBlockOperation Create() => CreateRollingQuantile();
        private static MathBlockOperation CreateRollingQuantile() => WithConstantWindowLength(MathBlockOperationFactory.Create("sequence.rolling-quantile", 3, VectorTwoScalarVectorType, inputs =>
        {
            var width = RequirePositiveInteger(inputs[1].AsScalar());
            var probability = inputs[2].AsScalar();
            var values = inputs[0].AsVector();
            return width <= values.Count && probability is >= 0f and <= 1f ? MathBlockValue.Vector(MathBlockVectorMath.RollingQuantile(values, width, probability), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit), "The inputs are outside the operation domain.");
        }, [sampleVector, MathBlockValue.Scalar(2f), MathBlockValue.Scalar(0.25f)], MathBlockValue.Vector([1.25f, 2.25f, 3.25f]), performanceIterations: 16), retainedRows: 1);
    }
}
