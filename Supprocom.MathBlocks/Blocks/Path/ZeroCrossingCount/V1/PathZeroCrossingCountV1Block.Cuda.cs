namespace Supprocom.MathBlocks.Cuda;

internal static class PathZeroCrossingCountV1BlockCuda
{
    internal const string Identity = "path.zero-crossing-count@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 31);
}
