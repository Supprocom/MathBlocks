namespace Supprocom.MathBlocks;

internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsHistogramV1Block
    {
        internal const string Identity = "statistics.histogram@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateHistogram();
        private static MathBlockOperation CreateHistogram() => MathBlockOperationFactory.Create("statistics.histogram", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
            if (types[0].Unit != types[1].Unit)
                throw new InvalidOperationException("The input units must be equal.");
            return MathBlockType.Vector();
        }, inputs =>
        {
            var boundaries = inputs[1].AsVector();
            for (var index = 1; index < boundaries.Count; index++)
                if (boundaries[index] <= boundaries[index - 1])
                    return MathBlockValue.Invalid(MathBlockType.Vector(), "The boundaries must increase strictly.");
            return MathBlockValue.Vector(MathBlockStatistics.Histogram(inputs[0].AsVector(), boundaries), default, true);
        }, [ascending, MathBlockValue.Vector([1.5f, 3.5f])], MathBlockValue.Vector([1f, 2f, 1f]), performanceIterations: 16);
    }
}
