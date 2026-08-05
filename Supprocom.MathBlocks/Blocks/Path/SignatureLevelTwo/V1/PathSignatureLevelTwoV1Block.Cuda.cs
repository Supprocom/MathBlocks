namespace Supprocom.MathBlocks.Cuda;

internal static class PathSignatureLevelTwoV1BlockCuda
{
    internal const string Identity = "path.signature-level-two@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 28);
}
