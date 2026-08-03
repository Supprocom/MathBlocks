namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class SequenceExponentialMovingAverageV1Block
    {
        internal const string Identity = "sequence.exponential-moving-average@1";
        internal static MathBlockOperation Create() => CreateEma();
        private static MathBlockOperation CreateEma() => MathBlockOperationFactory.Create("sequence.exponential-moving-average", 2, VectorScalarVectorType, inputs =>
        {
            var alpha = inputs[1].AsScalar();
            var values = inputs[0].AsVector();
            return values.Count > 0 && alpha is> 0d and <= 1d ? MathBlockValue.Vector(MathBlockVectorMath.ExponentialMovingAverage(values, alpha), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit), "The smoothing input is outside the operation domain.");
        }, [sampleVector, MathBlockValue.Scalar(0.5d)], MathBlockValue.Vector([1d, 1.5d, 2.25d, 3.125d]), performanceIterations: 64);
    }
}
