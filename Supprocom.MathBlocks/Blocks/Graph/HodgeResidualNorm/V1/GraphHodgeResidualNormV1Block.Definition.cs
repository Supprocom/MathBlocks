namespace Supprocom.MathBlocks;
internal static partial class GraphMathBlocks
{
    internal static class GraphHodgeResidualNormV1Block
    {
        internal const string Identity = "graph.hodge-residual-norm@1";
        internal static MathBlockOperation Create() => CreateHodgeResidual();
        private static MathBlockOperation CreateHodgeResidual() => MathBlockOperationFactory.Create("graph.hodge-residual-norm", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Graph);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
            if (types[0].Unit != types[1].Unit)
                throw new InvalidOperationException("The input units must be equal.");
            MathBlockTypeRules.RequireCompatibleShape(types[0], types[1]);
            return MathBlockType.Scalar(types[0].Unit);
        }, inputs => MathBlockValue.Scalar(MathBlockGraphMath.HodgeResidualNorm(inputs[0].AsGraph(), inputs[1].AsVector()), inputs[0].Type.Unit), [MathBlockValue.Graph(new MathBlockGraph(3, [new(0, 1, 1d), new(1, 2, 2d)])), MathBlockValue.Vector([0d, 1d, 3d])], MathBlockValue.Scalar(0d), performanceIterations: 4);
    }
}
