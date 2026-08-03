namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathDynamicTimeWarpingV1Block
    {
        internal const string Identity = "path.dynamic-time-warping@1";
        internal static MathBlockOperation Create() => CreateDynamicTimeWarping();
        private static MathBlockOperation CreateDynamicTimeWarping() => MathBlockOperationFactory.Create("path.dynamic-time-warping", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
            if (types[0].Unit != types[1].Unit)
                throw new InvalidOperationException("The path units must be equal.");
            return MathBlockType.Scalar(types[0].Unit);
        }, inputs => inputs[0].AsVector().Count > 0 && inputs[1].AsVector().Count > 0 ? MathBlockValue.Scalar(MathBlockPath.DynamicTimeWarpingDistance(inputs[0].AsVector(), inputs[1].AsVector()), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Scalar(inputs[0].Type.Unit), "A path is empty."), [MathBlockValue.Vector([1d, 2d]), MathBlockValue.Vector([1d, 3d])], MathBlockValue.Scalar(1d), performanceIterations: 8);
    }
}
