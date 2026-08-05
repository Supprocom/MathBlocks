namespace Supprocom.MathBlocks.Cuda;

internal static class PathRunLengthEncodeV1BlockCuda
{
    internal const string Identity = "path.run-length-encode@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 25);
}
