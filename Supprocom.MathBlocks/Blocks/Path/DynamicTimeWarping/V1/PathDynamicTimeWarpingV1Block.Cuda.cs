namespace Supprocom.MathBlocks.Cuda;

internal static class PathDynamicTimeWarpingV1BlockCuda
{
    internal const string Identity = "path.dynamic-time-warping@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 14);
}
