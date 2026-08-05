namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceRollingMinimumV1BlockCuda
{
    internal const string Identity = "sequence.rolling-minimum@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 6);
}
