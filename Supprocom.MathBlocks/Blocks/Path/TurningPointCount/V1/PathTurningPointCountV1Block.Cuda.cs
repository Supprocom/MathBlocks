namespace Supprocom.MathBlocks.Cuda;

internal static class PathTurningPointCountV1BlockCuda
{
    internal const string Identity = "path.turning-point-count@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 30);
}
