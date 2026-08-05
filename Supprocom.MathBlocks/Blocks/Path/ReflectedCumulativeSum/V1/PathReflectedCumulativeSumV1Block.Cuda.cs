namespace Supprocom.MathBlocks.Cuda;

internal static class PathReflectedCumulativeSumV1BlockCuda
{
    internal const string Identity = "path.reflected-cumulative-sum@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 24);
}
