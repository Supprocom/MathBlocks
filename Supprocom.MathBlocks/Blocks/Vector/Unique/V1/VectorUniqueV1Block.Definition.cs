namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class VectorUniqueV1Block
    {
        internal const string Identity = "vector.unique@1";
        internal static MathBlockOperation Create() => CreateUnique();
        private static MathBlockOperation CreateUnique() => MathBlockOperationFactory.Create("vector.unique", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            return MathBlockType.Vector(types[0].Unit);
        }, inputs => MathBlockValue.Vector(MathBlockStructure.Unique(inputs[0].AsVector()), inputs[0].Type.Unit, true), [MathBlockValue.Vector([1d, 2d, 1d])], MathBlockValue.Vector([1d, 2d]), performanceIterations: 16);
    }
}
