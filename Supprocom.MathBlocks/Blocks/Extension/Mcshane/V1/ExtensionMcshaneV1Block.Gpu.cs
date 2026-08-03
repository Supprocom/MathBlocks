namespace Supprocom.MathBlocks.Gpu;

internal static class ExtensionMcshaneV1BlockGpu
{
    internal const string Identity = "extension.mcshane@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 4);
}
