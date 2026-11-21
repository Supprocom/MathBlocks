namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class GeometrySimplicialDepthV1Block
    {
        internal const string Identity = "geometry.simplicial-depth@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateSimplicialDepth();
        private static MathBlockOperation CreateSimplicialDepth() => MathBlockOperationFactory.Create("geometry.simplicial-depth", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.PointSet);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.PointSet);
            if (types[0].Unit != types[1].Unit)
                throw new InvalidOperationException("The input units must be equal.");
            return MathBlockType.Scalar();
        }, inputs => inputs[0].AsPointSet().Count >= 3 && inputs[1].AsPointSet().Count == 1 ? MathBlockValue.Scalar(MathBlockAdvanced.SimplicialDepth(inputs[0].AsPointSet(), inputs[1].AsPointSet()[0])) : MathBlockValue.Invalid(MathBlockType.Scalar(), "The operation requires a sample and one point."), [MathBlockValue.PointSet(new MathBlockPointSet([new(0f, 0f), new(1f, 0f), new(0f, 1f)])), MathBlockValue.PointSet(new MathBlockPointSet([new(0.2f, 0.2f)]))], MathBlockValue.Scalar(1f), performanceIterations: 2);
    }
}
