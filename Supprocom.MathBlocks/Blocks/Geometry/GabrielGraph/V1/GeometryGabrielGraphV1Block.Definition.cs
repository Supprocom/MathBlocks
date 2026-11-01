namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class GeometryGabrielGraphV1Block
    {
        internal const string Identity = "geometry.gabriel-graph@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateGabrielGraph();
        private static MathBlockOperation CreateGabrielGraph() => MathBlockOperationFactory.Create("geometry.gabriel-graph", 1, GabrielType, inputs => inputs[0].AsPointSet().Count >= 2 ? MathBlockOperationFactory.Graph(MathBlockAdvanced.GabrielEdges(inputs[0].AsPointSet()), GabrielType, inputs) : MathBlockOperationFactory.Invalid(GabrielType, inputs, "The point set is too small."), [MathBlockValue.PointSet(new MathBlockPointSet([new(0d, 0d), new(1d, 0d), new(0d, 1d)]))], MathBlockValue.Graph(new MathBlockGraph(3, [new(0, 1, 1d), new(0, 2, 1d), new(1, 2, Math.Sqrt(2d))])), 1e-9, 2);

        private static MathBlockType GabrielType(IReadOnlyList<MathBlockType> types)
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.PointSet);
            return MathBlockType.Graph(types[0].Unit, types[0].Rows);
        }
    }
}
