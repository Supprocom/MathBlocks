namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceFirstTrueOffsetV1BlockCuda
{
    internal const string Identity = "sequence.first-true-offset@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 37);
}
