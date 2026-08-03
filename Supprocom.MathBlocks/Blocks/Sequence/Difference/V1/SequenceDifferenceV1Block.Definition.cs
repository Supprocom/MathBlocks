namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class SequenceDifferenceV1Block
    {
        internal const string Identity = "sequence.difference@1";
        internal static MathBlockOperation Create() => CreateDifference();
        private static MathBlockOperation CreateDifference() => MathBlockOperationFactory.Create("sequence.difference", 2, VectorScalarVectorType, inputs =>
        {
            var lag = RequirePositiveInteger(inputs[1].AsScalar());
            var values = inputs[0].AsVector();
            return lag < values.Count ? MathBlockValue.Vector(MathBlockVectorMath.Difference(values, lag), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit), "The lag is outside the sequence domain.");
        }, [sampleVector, MathBlockValue.Scalar(1d)], MathBlockValue.Vector([1d, 1d, 1d]), performanceIterations: 64);
    }
}
