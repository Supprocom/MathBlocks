namespace Supprocom.MathBlocks;
internal static partial class GraphMathBlocks
{
    internal static class GraphIsConnectedV1Block
    {
        internal const string Identity = "graph.is-connected@1";
        internal static MathBlockOperation Create() => CreateBoolean("graph.is-connected", MathBlockGraphMath.IsConnected, path, true);
        private static MathBlockOperation CreateBoolean(string identifier, Func<MathBlockGraph, bool> function, MathBlockValue sample, bool expected) => MathBlockOperationFactory.Create(identifier, 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Graph);
            return MathBlockType.Boolean;
        }, inputs => MathBlockValue.Boolean(function(inputs[0].AsGraph())), [sample], MathBlockValue.Boolean(expected), performanceIterations: 8);
    }
}
