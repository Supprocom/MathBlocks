namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class SequenceFirstTrueOffsetV1Block
    {
        internal const string Identity = "sequence.first-true-offset@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Forward;
        internal static MathBlockOperation Create() => CreateFirstTrueOffset(false);
    }
}
