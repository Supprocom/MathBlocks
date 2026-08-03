namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class SequenceRollingQuantileV1Block
    {
        internal const string Identity = "sequence.rolling-quantile@1";
        internal static MathBlockOperation Create() => CreateRollingQuantile();
        private static MathBlockOperation CreateRollingQuantile() => MathBlockOperationFactory.Create("sequence.rolling-quantile", 3, VectorTwoScalarVectorType, inputs =>
        {
            var width = RequirePositiveInteger(inputs[1].AsScalar());
            var probability = inputs[2].AsScalar();
            var values = inputs[0].AsVector();
            return width <= values.Count && probability is >= 0d and <= 1d ? MathBlockValue.Vector(MathBlockVectorMath.RollingQuantile(values, width, probability), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit), "The inputs are outside the operation domain.");
        }, [sampleVector, MathBlockValue.Scalar(2d), MathBlockValue.Scalar(0.25d)], MathBlockValue.Vector([1.25d, 2.25d, 3.25d]), performanceIterations: 16);
    }
}
