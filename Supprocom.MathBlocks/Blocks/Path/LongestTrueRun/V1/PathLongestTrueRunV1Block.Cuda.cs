namespace Supprocom.MathBlocks.Cuda;

internal static class PathLongestTrueRunV1BlockCuda
{
    internal const string Identity = "path.longest-true-run@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 18);
}
