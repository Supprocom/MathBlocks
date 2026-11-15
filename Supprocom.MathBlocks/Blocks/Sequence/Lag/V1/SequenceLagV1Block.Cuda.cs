namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceLagV1BlockCuda
{
    internal const string Identity = "sequence.lag@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 35);
}
