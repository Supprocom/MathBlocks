namespace Supprocom.MathBlocks.Gpu;

internal static class InformationRenyiEntropyV1BlockGpu
{
    internal const string Identity = "information.renyi-entropy@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 13);
}
