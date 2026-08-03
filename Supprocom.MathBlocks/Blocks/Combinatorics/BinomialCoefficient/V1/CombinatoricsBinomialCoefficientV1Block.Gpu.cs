namespace Supprocom.MathBlocks.Gpu;

internal static class CombinatoricsBinomialCoefficientV1BlockGpu
{
    internal const string Identity = "combinatorics.binomial-coefficient@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 1);
}
