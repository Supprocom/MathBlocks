namespace Supprocom.MathBlocks.Cuda;

internal static class PathTotalVariationV1BlockCuda
{
    internal const string Identity = "path.total-variation@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 29);
}
