namespace Supprocom.MathBlocks.Gpu;

internal static class InformationKullbackLeiblerV1BlockGpu
{
    internal const string Identity = "information.kullback-leibler@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 11);
}
