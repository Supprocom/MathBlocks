namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceLagValidV1BlockCuda
{
    internal const string Identity = "sequence.lag-valid@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 36);
}
