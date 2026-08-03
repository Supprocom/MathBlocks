namespace Supprocom.MathBlocks.Gpu;

internal static class InformationShannonEntropyV1BlockGpu
{
    internal const string Identity = "information.shannon-entropy@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 14);
}
