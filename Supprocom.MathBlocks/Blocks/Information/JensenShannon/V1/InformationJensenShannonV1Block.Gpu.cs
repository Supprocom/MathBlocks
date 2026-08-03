namespace Supprocom.MathBlocks.Gpu;

internal static class InformationJensenShannonV1BlockGpu
{
    internal const string Identity = "information.jensen-shannon@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 10);
}
