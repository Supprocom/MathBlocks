namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class SequenceFirstTrueOffsetValidV1Block
    {
        internal const string Identity = "sequence.first-true-offset-valid@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Forward;
        internal static MathBlockOperation Create() => CreateFirstTrueOffset(true);
    }
}
