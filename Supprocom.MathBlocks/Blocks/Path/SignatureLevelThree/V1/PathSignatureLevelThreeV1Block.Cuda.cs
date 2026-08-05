namespace Supprocom.MathBlocks.Cuda;

internal static class PathSignatureLevelThreeV1BlockCuda
{
    internal const string Identity = "path.signature-level-three@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 27);
}
