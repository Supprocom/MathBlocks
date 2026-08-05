namespace Supprocom.MathBlocks.Cuda;

internal static class CombinatoricsFactorialV1BlockCuda
{
    internal const string Identity = "combinatorics.factorial@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 2);
}
