namespace Supprocom.MathBlocks;
internal static partial class VectorMathBlocks
{
    internal static class BooleanVectorNotV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateBooleanVectorNot();
        private static MathBlockOperation CreateBooleanVectorNot() => MathBlockOperationFactory.Create(
            "boolean-vector.not",
            1,
            types => MathBlockTypeRules.Unary(types, MathBlockValueKind.BooleanVector),
            inputs => MathBlockValue.BooleanVector(
                MathBlockCollectionPrimitives.Map(inputs[0].AsBooleanVector(), value => !value),
                true),
            [MathBlockValue.BooleanVector([true, false])],
            MathBlockValue.BooleanVector([false, true]),
            performanceIterations: 64);
    }
}
