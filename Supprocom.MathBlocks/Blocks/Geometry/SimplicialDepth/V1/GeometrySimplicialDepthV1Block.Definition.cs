namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class GeometrySimplicialDepthV1Block
    {
        internal const string Identity = "geometry.simplicial-depth@1";
        internal static MathBlockOperation Create() => CreateSimplicialDepth();
        private static MathBlockOperation CreateSimplicialDepth() => MathBlockOperationFactory.Create("geometry.simplicial-depth", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.PointSet);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.PointSet);
            if (types[0].Unit != types[1].Unit)
                throw new InvalidOperationException("The input units must be equal.");
            return MathBlockType.Scalar();
        }, inputs => inputs[0].AsPointSet().Count >= 3 && inputs[1].AsPointSet().Count == 1 ? MathBlockValue.Scalar(MathBlockAdvanced.SimplicialDepth(inputs[0].AsPointSet(), inputs[1].AsPointSet()[0])) : MathBlockValue.Invalid(MathBlockType.Scalar(), "The operation requires a sample and one point."), [MathBlockValue.PointSet(new MathBlockPointSet([new(0d, 0d), new(1d, 0d), new(0d, 1d)])), MathBlockValue.PointSet(new MathBlockPointSet([new(0.2d, 0.2d)]))], MathBlockValue.Scalar(1d), performanceIterations: 2);
    }
}
