namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorQuantileV1Block
    {
        internal const string Identity = "vector.quantile@1";
        internal static MathBlockOperation Create() => CreateQuantile();
        private static MathBlockOperation CreateQuantile() => MathBlockOperationFactory.Create("vector.quantile", 2, VectorScalarReductionType, inputs =>
        {
            var probability = inputs[1].AsScalar();
            return probability is >= 0d and <= 1d && inputs[0].AsVector().Count > 0 ? MathBlockValue.Scalar(MathBlockVectorMath.Quantile(inputs[0].AsVector(), probability), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Scalar(inputs[0].Type.Unit), "The probability or vector is outside the operation domain.");
        }, [sampleVector, MathBlockValue.Scalar(0.25d)], MathBlockValue.Scalar(1.75d), 1e-9, 64);
    }
}
