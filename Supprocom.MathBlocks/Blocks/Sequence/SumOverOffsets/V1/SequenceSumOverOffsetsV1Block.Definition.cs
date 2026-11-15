namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class SequenceSumOverOffsetsV1Block
    {
        internal const string Identity = "sequence.sum-over-offsets@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Forward;
        internal static MathBlockOperation Create() => CreateSumOverOffsets(false);
    }
}
