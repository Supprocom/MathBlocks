namespace Supprocom.MathBlocks;

internal static partial class GeometryMathBlocks
{
    internal static class GeometryConvexHullV1Block
    {
        internal const string Identity = "geometry.convex-hull@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateConvexHull();
        private static MathBlockValue HullOrInvalid(IReadOnlyList<MathBlockValue> inputs)
        {
            try
            {
                return MathBlockValue.PointSet(new MathBlockPointSet(MathBlockGeometry.ConvexHull(inputs[0].AsPointSet())), inputs[0].Type.Unit);
            }
            catch (OverflowException)
            {
                return MathBlockOperationFactory.Invalid(SamePointSet, inputs, "A cross product overflowed.");
            }
        }

        private static MathBlockOperation CreateConvexHull() => MathBlockOperationFactory.Create("geometry.convex-hull", 1, SamePointSet, inputs => inputs[0].AsPointSet().Count > 0 ? HullOrInvalid(inputs) : MathBlockValue.Invalid(MathBlockType.PointSet(inputs[0].Type.Unit), "The point set is empty."), [MathBlockValue.PointSet(new MathBlockPointSet([new(0f, 0f), new(1f, 0f), new(0.5f, 0.5f), new(1f, 1f), new(0f, 1f)]))], square, performanceIterations: 4);
    }
}
