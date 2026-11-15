namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class SequenceLeadValidV1Block
    {
        internal const string Identity = "sequence.lead-valid@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Forward;
        internal static MathBlockOperation Create() => MathBlockSequenceShift.Create("sequence.lead-valid", lead: true, validity: true, Causality);
    }
}
