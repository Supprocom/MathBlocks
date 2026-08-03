namespace Supprocom.MathBlocks.Gpu;

internal static class InformationConditionalMutualInformationV1BlockGpu
{
    internal const string Identity = "information.conditional-mutual-information@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 6);
}
