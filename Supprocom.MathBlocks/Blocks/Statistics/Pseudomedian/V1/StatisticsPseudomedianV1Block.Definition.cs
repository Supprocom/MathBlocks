namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class StatisticsPseudomedianV1Block
    {
        internal const string Identity = "statistics.pseudomedian@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateVectorScalar("statistics.pseudomedian", MathBlockAdvanced.Pseudomedian, MathBlockValue.Vector([1f, 3f]), 2f, SameUnitScalar);
    }
}
