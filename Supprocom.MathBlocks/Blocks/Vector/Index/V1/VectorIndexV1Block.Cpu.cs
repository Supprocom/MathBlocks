namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorIndexV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateIndex();
        private static MathBlockOperation CreateIndex() => MathBlockOperationFactory.Create("vector.index", 2, VectorScalarReductionType, inputs =>
        {
            var index = RequireNonnegativeInteger(inputs[1].AsScalar());
            var values = inputs[0].AsVector();
            return index < values.Count ? MathBlockValue.Scalar(values[index], inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Scalar(inputs[0].Type.Unit), "The index is outside the vector domain.");
        }, [sampleVector, MathBlockValue.Scalar(2d)], MathBlockValue.Scalar(3d), performanceIterations: 128);
    }
}
