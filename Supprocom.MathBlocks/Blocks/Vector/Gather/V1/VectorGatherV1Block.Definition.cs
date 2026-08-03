namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class VectorGatherV1Block
    {
        internal const string Identity = "vector.gather@1";
        internal static MathBlockOperation Create() => CreateGather();
        private static MathBlockOperation CreateGather() => MathBlockOperationFactory.Create("vector.gather", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireDimensionless(types[1]);
            return MathBlockType.Vector(types[0].Unit, types[1].Rows);
        }, inputs => MathBlockCollectionPrimitives.All(
            inputs[1].AsVector(),
            value => TryNonnegativeInteger(value, out var index) && index < inputs[0].AsVector().Count)
            ? MathBlockValue.Vector(
                MathBlockStructure.Gather(inputs[0].AsVector(), inputs[1].AsVector()),
                inputs[0].Type.Unit,
                true)
            : MathBlockValue.Invalid(
                MathBlockType.Vector(inputs[0].Type.Unit),
                "An index is outside the vector domain."),
            [vector, MathBlockValue.Vector([3d, 1d])],
            MathBlockValue.Vector([4d, 2d]),
            performanceIterations: 16);
    }
}
