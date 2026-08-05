namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceRollingMedianV1BlockCuda
{
    internal const string Identity = "sequence.rolling-median@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 5);
}
