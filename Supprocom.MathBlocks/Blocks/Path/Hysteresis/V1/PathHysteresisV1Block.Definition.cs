namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathHysteresisV1Block
    {
        internal const string Identity = "path.hysteresis@1";
        internal static MathBlockOperation Create() => CreateHysteresis();
        private static MathBlockOperation CreateHysteresis() => MathBlockOperationFactory.Create("path.hysteresis", 3, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
            MathBlockTypeRules.RequireKind(types[2], MathBlockValueKind.Scalar);
            if (types[0].Unit != types[1].Unit || types[0].Unit != types[2].Unit)
                throw new InvalidOperationException("The input units must be equal.");
            return MathBlockType.Vector(length: types[0].Rows);
        }, inputs => inputs[1].AsScalar() < inputs[2].AsScalar() ? MathBlockValue.Vector(MathBlockPath.Hysteresis(inputs[0].AsVector(), inputs[1].AsScalar(), inputs[2].AsScalar()), default, true) : MathBlockValue.Invalid(MathBlockType.Vector(), "The lower threshold must be less than the upper threshold."), [MathBlockValue.Vector([-2d, 0d, 2d, 0d, -2d]), MathBlockValue.Scalar(-1d), MathBlockValue.Scalar(1d)], MathBlockValue.Vector([-1d, -1d, 1d, 1d, -1d]), performanceIterations: 16);
    }
}
