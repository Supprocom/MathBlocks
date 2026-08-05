namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceRollingQuantileV1BlockCuda
{
    internal const string Identity = "sequence.rolling-quantile@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 7);
}
