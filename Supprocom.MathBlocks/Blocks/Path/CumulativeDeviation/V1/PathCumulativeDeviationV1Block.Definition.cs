namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathCumulativeDeviationV1Block
    {
        internal const string Identity = "path.cumulative-deviation@1";
        internal static MathBlockOperation Create() => CreateCumulativeDeviation();
        private static MathBlockOperation CreateCumulativeDeviation() => MathBlockOperationFactory.Create("path.cumulative-deviation", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
            if (types[0].Unit != types[1].Unit)
                throw new InvalidOperationException("The input units must be equal.");
            return types[0];
        }, inputs => MathBlockValue.Vector(MathBlockPath.CumulativeDeviation(inputs[0].AsVector(), inputs[1].AsScalar()), inputs[0].Type.Unit, true), [MathBlockValue.Vector([2d, 3d, 1d]), MathBlockValue.Scalar(2d)], MathBlockValue.Vector([0d, 1d, 0d]), performanceIterations: 16);
    }
}
