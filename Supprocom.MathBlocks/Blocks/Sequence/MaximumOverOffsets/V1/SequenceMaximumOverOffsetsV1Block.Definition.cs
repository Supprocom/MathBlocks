namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class SequenceMaximumOverOffsetsV1Block
    {
        internal const string Identity = "sequence.maximum-over-offsets@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Forward;
        internal static MathBlockOperation Create() => CreateMaximumOverOffsets(false);
    }
}
