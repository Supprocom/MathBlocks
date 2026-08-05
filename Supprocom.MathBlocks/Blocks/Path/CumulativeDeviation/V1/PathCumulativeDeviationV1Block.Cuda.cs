namespace Supprocom.MathBlocks.Cuda;

internal static class PathCumulativeDeviationV1BlockCuda
{
    internal const string Identity = "path.cumulative-deviation@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 13);
}
