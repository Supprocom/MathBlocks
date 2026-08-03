namespace Supprocom.MathBlocks.Gpu;

internal static class ExtensionWhitneyV1BlockGpu
{
    internal const string Identity = "extension.whitney@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 5);
}
