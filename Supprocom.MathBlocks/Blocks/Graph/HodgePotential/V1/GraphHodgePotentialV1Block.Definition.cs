namespace Supprocom.MathBlocks;
internal static partial class GraphMathBlocks
{
    internal static class GraphHodgePotentialV1Block
    {
        internal const string Identity = "graph.hodge-potential@1";
        internal static MathBlockOperation Create() => CreateHodgePotential();
        private static MathBlockOperation CreateHodgePotential() => MathBlockOperationFactory.Create("graph.hodge-potential", 1, WeightedGraphVector, inputs => MathBlockGraphMath.TryHodgePotential(inputs[0].AsGraph(), out var potential) ? MathBlockValue.Vector(potential, inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit), "The graph does not have a unique anchored potential."), [MathBlockValue.Graph(new MathBlockGraph(3, [new(0, 1, 1d), new(1, 2, 2d)]))], MathBlockValue.Vector([0d, 1d, 3d]), performanceIterations: 4);
    }
}
