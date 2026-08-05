namespace Supprocom.MathBlocks.Cuda;

internal static class CombinatoricsBallotCountV1BlockCuda
{
    internal const string Identity = "combinatorics.ballot-count@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 0);
}
