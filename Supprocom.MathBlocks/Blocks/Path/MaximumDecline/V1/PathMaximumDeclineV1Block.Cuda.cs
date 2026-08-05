namespace Supprocom.MathBlocks.Cuda;

internal static class PathMaximumDeclineV1BlockCuda
{
    internal const string Identity = "path.maximum-decline@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 19);
}
