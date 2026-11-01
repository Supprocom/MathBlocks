namespace Supprocom.MathBlocks;

internal static partial class GeometryMathBlocks
{
    internal static class TopologyZeroDimensionalPersistenceV1Block
    {
        internal const string Identity = "topology.zero-dimensional-persistence@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateZeroDimensionalPersistence();
        private static MathBlockOperation CreateZeroDimensionalPersistence() => MathBlockOperationFactory.Create("topology.zero-dimensional-persistence", 1, PersistenceType, inputs => inputs[0].AsPointSet().Count > 0 ? MathBlockValue.Vector(MathBlockGeometry.ZeroDimensionalPersistence(inputs[0].AsPointSet()), inputs[0].Type.Unit, true) : MathBlockOperationFactory.Invalid(PersistenceType, inputs, "The point set is empty."), [MathBlockValue.PointSet(new MathBlockPointSet([new(0d, 0d), new(1d, 0d), new(0d, 1d)]))], MathBlockValue.Vector([1d, 1d]), performanceIterations: 2);

        // A spanning forest of the complete graph on n points has n - 1 edges, so n points give n - 1 death times.
        private static MathBlockType PersistenceType(IReadOnlyList<MathBlockType> types)
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.PointSet);
            return MathBlockType.Vector(types[0].Unit, types[0].Rows > 1 ? types[0].Rows - 1 : 0);
        }
    }
}
