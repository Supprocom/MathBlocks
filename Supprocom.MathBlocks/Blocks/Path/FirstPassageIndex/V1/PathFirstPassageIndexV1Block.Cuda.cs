namespace Supprocom.MathBlocks.Cuda;

internal static class PathFirstPassageIndexV1BlockCuda
{
    internal const string Identity = "path.first-passage-index@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 15);
}
