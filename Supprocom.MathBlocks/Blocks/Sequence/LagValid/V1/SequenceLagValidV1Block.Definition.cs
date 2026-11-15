namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class SequenceLagValidV1Block
    {
        internal const string Identity = "sequence.lag-valid@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Expanding;
        internal static MathBlockOperation Create() => MathBlockSequenceShift.Create("sequence.lag-valid", lead: false, validity: true, Causality);
    }
}
