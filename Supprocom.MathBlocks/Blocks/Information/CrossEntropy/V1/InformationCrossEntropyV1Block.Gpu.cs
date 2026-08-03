namespace Supprocom.MathBlocks.Gpu;

internal static class InformationCrossEntropyV1BlockGpu
{
    internal const string Identity = "information.cross-entropy@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 7);
}
