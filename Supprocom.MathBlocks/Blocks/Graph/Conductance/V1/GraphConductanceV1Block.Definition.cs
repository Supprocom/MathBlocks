namespace Supprocom.MathBlocks;
internal static partial class GraphMathBlocks
{
    internal static class GraphConductanceV1Block
    {
        internal const string Identity = "graph.conductance@1";
        internal static MathBlockOperation Create() => CreateConductance();
        private static MathBlockOperation CreateConductance() => MathBlockOperationFactory.Create("graph.conductance", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Graph);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.BooleanVector);
            MathBlockTypeRules.RequireCompatibleShape(types[0], types[1]);
            return MathBlockType.Scalar();
        }, inputs =>
        {
            var graph = inputs[0].AsGraph();
            var subset = inputs[1].AsBooleanVector();
            return MathBlockCollectionPrimitives.Any(graph, edge => edge.Weight < 0d) ||
                   MathBlockCollectionPrimitives.All(subset, value => value) ||
                   MathBlockCollectionPrimitives.All(subset, value => !value)
                ? MathBlockValue.Invalid(
                    MathBlockType.Scalar(),
                    "The graph or subset is outside the operation domain.")
                : MathBlockValue.Scalar(MathBlockGraphMath.Conductance(graph, subset));
        }, [path, MathBlockValue.BooleanVector([true, false, false ])], MathBlockValue.Scalar(1d), performanceIterations: 4);
    }
}
