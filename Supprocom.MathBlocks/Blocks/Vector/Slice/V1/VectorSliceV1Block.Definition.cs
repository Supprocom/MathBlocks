namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class VectorSliceV1Block
    {
        internal const string Identity = "vector.slice@1";
        internal static MathBlockOperation Create() => CreateSlice();
        private static MathBlockOperation CreateSlice() => MathBlockOperationFactory.Create("vector.slice", 3, VectorTwoScalarVectorType, inputs =>
        {
            var start = RequireNonnegativeInteger(inputs[1].AsScalar());
            var length = RequireNonnegativeInteger(inputs[2].AsScalar());
            var values = inputs[0].AsVector();
            return start <= values.Count && length <= values.Count - start ? MathBlockValue.Vector(MathBlockVectorMath.Slice(values, start, length), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit), "The slice is outside the vector domain.");
        }, [sampleVector, MathBlockValue.Scalar(1d), MathBlockValue.Scalar(2d)], MathBlockValue.Vector([2d, 3d]), performanceIterations: 64);
    }
}
