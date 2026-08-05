namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceRollingVarianceV1BlockCuda
{
    internal const string Identity = "sequence.rolling-variance@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 10);
}
