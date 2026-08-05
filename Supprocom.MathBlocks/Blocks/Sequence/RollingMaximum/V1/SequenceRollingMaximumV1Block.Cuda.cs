namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceRollingMaximumV1BlockCuda
{
    internal const string Identity = "sequence.rolling-maximum@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 3);
}
