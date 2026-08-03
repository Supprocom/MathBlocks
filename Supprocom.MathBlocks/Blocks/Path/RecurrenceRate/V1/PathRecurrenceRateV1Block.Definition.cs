namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathRecurrenceRateV1Block
    {
        internal const string Identity = "path.recurrence-rate@1";
        internal static MathBlockOperation Create() => CreateRecurrenceRate();
        private static MathBlockOperation CreateRecurrenceRate() => MathBlockOperationFactory.Create("path.recurrence-rate", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
            if (types[0].Unit != types[1].Unit)
                throw new InvalidOperationException("The path and threshold units must be equal.");
            return MathBlockType.Scalar();
        }, inputs => inputs[0].AsVector().Count > 0 && inputs[1].AsScalar() >= 0d ? MathBlockValue.Scalar(MathBlockPath.RecurrenceRate(inputs[0].AsVector(), inputs[1].AsScalar())) : MathBlockValue.Invalid(MathBlockType.Scalar(), "The inputs are outside the operation domain."), [MathBlockValue.Vector([1d, 1d]), MathBlockValue.Scalar(0d)], MathBlockValue.Scalar(1d), performanceIterations: 8);
    }
}
