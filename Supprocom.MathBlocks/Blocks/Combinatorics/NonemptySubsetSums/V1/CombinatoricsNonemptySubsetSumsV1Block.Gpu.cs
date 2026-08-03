namespace Supprocom.MathBlocks.Gpu;

internal static class CombinatoricsNonemptySubsetSumsV1BlockGpu
{
    internal const string Identity = "combinatorics.nonempty-subset-sums@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 3);
}
