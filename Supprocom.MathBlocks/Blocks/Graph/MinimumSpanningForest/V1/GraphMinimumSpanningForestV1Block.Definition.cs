namespace Supprocom.MathBlocks;
internal static partial class GraphMathBlocks
{
    internal static class GraphMinimumSpanningForestV1Block
    {
        internal const string Identity = "graph.minimum-spanning-forest@1";
        internal static MathBlockOperation Create() => CreateMinimumSpanningForest();
        private static MathBlockOperation CreateMinimumSpanningForest() => MathBlockOperationFactory.Create("graph.minimum-spanning-forest", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Graph);
            return types[0];
        }, inputs => MathBlockValue.Graph(MathBlockGraphMath.MinimumSpanningForest(inputs[0].AsGraph()), inputs[0].Type.Unit), [triangle], MathBlockValue.Graph(new MathBlockGraph(3, [new(0, 1, 1d), new(0, 2, 1d)])), performanceIterations: 4);
    }
}
