namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceRollingMeanV1BlockCuda
{
    internal const string Identity = "sequence.rolling-mean@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 4);
}
