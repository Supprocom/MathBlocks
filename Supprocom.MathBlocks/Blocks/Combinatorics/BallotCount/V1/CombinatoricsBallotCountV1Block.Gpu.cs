namespace Supprocom.MathBlocks.Gpu;

internal static class CombinatoricsBallotCountV1BlockGpu
{
    internal const string Identity = "combinatorics.ballot-count@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 0);
}
