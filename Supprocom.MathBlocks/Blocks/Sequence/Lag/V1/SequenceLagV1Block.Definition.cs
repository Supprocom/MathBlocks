namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class SequenceLagV1Block
    {
        internal const string Identity = "sequence.lag@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Expanding;
        internal static MathBlockOperation Create() => MathBlockSequenceShift.Create("sequence.lag", lead: false, validity: false, Causality);
    }
}
