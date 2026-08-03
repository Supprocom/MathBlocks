namespace Supprocom.MathBlocks.Gpu;

internal static class InformationTsallisEntropyV1BlockGpu
{
    internal const string Identity = "information.tsallis-entropy@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 16);
}
