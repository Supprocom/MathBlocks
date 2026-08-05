namespace Supprocom.MathBlocks.Cuda;

internal static class PathSignatureLevelOneV1BlockCuda
{
    internal const string Identity = "path.signature-level-one@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 26);
}
