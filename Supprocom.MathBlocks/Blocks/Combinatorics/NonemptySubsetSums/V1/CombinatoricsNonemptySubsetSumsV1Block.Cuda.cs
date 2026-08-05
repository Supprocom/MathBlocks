namespace Supprocom.MathBlocks.Cuda;

internal static class CombinatoricsNonemptySubsetSumsV1BlockCuda
{
    internal const string Identity = "combinatorics.nonempty-subset-sums@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 3);
}
