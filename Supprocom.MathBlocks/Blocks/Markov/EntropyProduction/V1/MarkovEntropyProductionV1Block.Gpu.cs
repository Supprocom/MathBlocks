namespace Supprocom.MathBlocks.Gpu;

internal static class MarkovEntropyProductionV1BlockGpu
{
    internal const string Identity = "markov.entropy-production@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 8);
}
