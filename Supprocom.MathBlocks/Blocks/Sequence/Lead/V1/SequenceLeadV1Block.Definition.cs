namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class SequenceLeadV1Block
    {
        internal const string Identity = "sequence.lead@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Forward;
        internal static MathBlockOperation Create() => MathBlockSequenceShift.Create("sequence.lead", lead: true, validity: false, Causality);
    }
}
