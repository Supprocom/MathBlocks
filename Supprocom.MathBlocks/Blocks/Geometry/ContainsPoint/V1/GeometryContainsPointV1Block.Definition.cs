namespace Supprocom.MathBlocks;
internal static partial class GeometryMathBlocks
{
    internal static class GeometryContainsPointV1Block
    {
        internal const string Identity = "geometry.contains-point@1";
        internal static MathBlockOperation Create() => CreateContains();
        private static MathBlockOperation CreateContains() => MathBlockOperationFactory.Create("geometry.contains-point", 2, types =>
        {
            PointPairLengthType(types);
            return MathBlockType.Boolean;
        }, inputs => inputs[0].AsPointSet().Count >= 3 && inputs[1].AsPointSet().Count == 1 ? MathBlockValue.Boolean(MathBlockGeometry.ContainsPoint(inputs[0].AsPointSet(), inputs[1].AsPointSet()[0])) : MathBlockValue.Invalid(MathBlockType.Boolean, "The operation requires a polygon and one point."), [square, Singleton(0.5d, 0.5d)], MathBlockValue.Boolean(true), performanceIterations: 8);
    }
}
