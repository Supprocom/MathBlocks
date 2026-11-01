namespace Supprocom.MathBlocks;

internal static partial class GeometryMathBlocks
{
    internal static class GeometryCentroidV1Block
    {
        internal const string Identity = "geometry.centroid@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateCentroid();
        private static MathBlockOperation CreateCentroid() => MathBlockOperationFactory.Create("geometry.centroid", 1, CentroidType, inputs => inputs[0].AsPointSet().Count > 0 ? CentroidOrInvalid(inputs) : MathBlockOperationFactory.Invalid(CentroidType, inputs, "The point set is empty."), [square], Singleton(0.5d, 0.5d), performanceIterations: 8);

        // The centroid is one point.
        private static MathBlockType CentroidType(IReadOnlyList<MathBlockType> types) =>
            MathBlockType.PointSet(SamePointSet(types).Unit, 1);

        // The coordinate sums overflow for points near the largest finite values.
        private static MathBlockValue CentroidOrInvalid(IReadOnlyList<MathBlockValue> inputs)
        {
            var centroid = MathBlockGeometry.Centroid(inputs[0].AsPointSet());
            return Math.IsFinite(centroid.X) && Math.IsFinite(centroid.Y)
                ? MathBlockValue.PointSet(new MathBlockPointSet([centroid]), inputs[0].Type.Unit)
                : MathBlockOperationFactory.Invalid(CentroidType, inputs, "The centroid is not finite.");
        }
    }
}
