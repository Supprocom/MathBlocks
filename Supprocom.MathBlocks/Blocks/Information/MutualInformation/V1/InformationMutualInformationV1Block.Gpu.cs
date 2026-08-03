namespace Supprocom.MathBlocks.Gpu;

internal static class InformationMutualInformationV1BlockGpu
{
    internal const string Identity = "information.mutual-information@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 12);
}
