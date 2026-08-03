namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class StateTransitionCountsV1Block
    {
        internal const string Identity = "state.transition-counts@1";
        internal static MathBlockOperation Create() => CreateTransitionCounts();
        private static MathBlockOperation CreateTransitionCounts() => MathBlockOperationFactory.Create("state.transition-counts", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
            MathBlockTypeRules.RequireDimensionless(types[1]);
            return MathBlockType.Matrix();
        }, inputs =>
        {
            var states = inputs[0].AsVector();
            var countValue = inputs[1].AsScalar();
            if (countValue != Math.Truncate(countValue) ||
                countValue <= 0d ||
                countValue > 4096d ||
                MathBlockCollectionPrimitives.Any(
                    states,
                    value => value != Math.Truncate(value) || value < 0d || value >= countValue))
                return MathBlockValue.Invalid(MathBlockType.Matrix(), "The state inputs are outside the operation domain.");
            return MathBlockValue.Matrix(MathBlockPath.TransitionCounts(states, (int)countValue));
        }, [MathBlockValue.Vector([0d, 1d, 1d, 0d]), MathBlockValue.Scalar(2d)], MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0d, 1d, 1d, 1d])), performanceIterations: 8);
    }
}
