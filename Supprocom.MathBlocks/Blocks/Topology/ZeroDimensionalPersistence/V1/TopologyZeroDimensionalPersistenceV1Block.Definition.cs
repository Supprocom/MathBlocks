namespace Supprocom.MathBlocks;
internal static partial class GeometryMathBlocks
{
    internal static class TopologyZeroDimensionalPersistenceV1Block
    {
        internal const string Identity = "topology.zero-dimensional-persistence@1";
        internal static MathBlockOperation Create() => CreateZeroDimensionalPersistence();
        private static MathBlockOperation CreateZeroDimensionalPersistence() => MathBlockOperationFactory.Create("topology.zero-dimensional-persistence", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.PointSet);
            return MathBlockType.Vector(types[0].Unit);
        }, inputs => inputs[0].AsPointSet().Count > 0 ? MathBlockValue.Vector(MathBlockGeometry.ZeroDimensionalPersistence(inputs[0].AsPointSet()), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit), "The point set is empty."), [MathBlockValue.PointSet(new MathBlockPointSet([new(0d, 0d), new(1d, 0d), new(0d, 1d)]))], MathBlockValue.Vector([1d, 1d]), performanceIterations: 2);
    }
}
