namespace Supprocom.MathBlocks.Gpu;

internal static class ProbabilityNormalizeV1BlockGpu
{
    internal const string Identity = "probability.normalize@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 24);
}
