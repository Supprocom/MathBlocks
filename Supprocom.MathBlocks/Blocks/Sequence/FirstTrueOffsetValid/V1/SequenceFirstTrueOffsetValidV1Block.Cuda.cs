namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceFirstTrueOffsetValidV1BlockCuda
{
    internal const string Identity = "sequence.first-true-offset-valid@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 38);
}
