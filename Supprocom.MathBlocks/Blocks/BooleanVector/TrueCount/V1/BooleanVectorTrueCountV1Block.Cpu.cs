namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class BooleanVectorTrueCountV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateBooleanCount();
        private static MathBlockOperation CreateBooleanCount() => MathBlockOperationFactory.Create("boolean-vector.true-count", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.BooleanVector);
            return MathBlockType.Scalar();
        }, inputs => MathBlockValue.Scalar(
            MathBlockCollectionPrimitives.Count(inputs[0].AsBooleanVector(), value => value)),
            [MathBlockValue.BooleanVector([true, false, true])],
            MathBlockValue.Scalar(2d),
            performanceIterations: 32);
    }
}
