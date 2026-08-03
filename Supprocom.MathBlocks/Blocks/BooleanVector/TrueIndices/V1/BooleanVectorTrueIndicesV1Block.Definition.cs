namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class BooleanVectorTrueIndicesV1Block
    {
        internal const string Identity = "boolean-vector.true-indices@1";
        internal static MathBlockOperation Create() => CreateTrueIndices();
        private static MathBlockOperation CreateTrueIndices() => MathBlockOperationFactory.Create("boolean-vector.true-indices", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.BooleanVector);
            return MathBlockType.Vector();
        }, inputs => MathBlockValue.Vector(MathBlockStructure.TrueIndices(inputs[0].AsBooleanVector()), default, true), [MathBlockValue.BooleanVector([false, true, false, true ])], MathBlockValue.Vector([1d, 3d]), performanceIterations: 16);
    }
}
