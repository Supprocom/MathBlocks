namespace Supprocom.MathBlocks.Cuda;

internal static class PathMaximumRelativeDeclineV1BlockCuda
{
    internal const string Identity = "path.maximum-relative-decline@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 20);
}
