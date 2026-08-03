namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsAutocorrelationV1Block
    {
        internal const string Identity = "statistics.autocorrelation@1";
        internal static MathBlockOperation Create() => CreateAutocorrelation();
        private static MathBlockOperation CreateAutocorrelation() => MathBlockOperationFactory.Create("statistics.autocorrelation", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
            MathBlockTypeRules.RequireDimensionless(types[1]);
            return MathBlockType.Scalar();
        }, inputs =>
        {
            var lagValue = inputs[1].AsScalar();
            var values = inputs[0].AsVector();
            return lagValue == Math.Truncate(lagValue) && lagValue > 0d && lagValue < values.Count ? MathBlockValue.Scalar(MathBlockStatistics.Autocorrelation(values, (int)lagValue)) : MathBlockValue.Invalid(MathBlockType.Scalar(), "The lag is outside the operation domain.");
        }, [ascending, MathBlockValue.Scalar(1d)], MathBlockValue.Scalar(1d), 1e-9, 16);
    }
}
