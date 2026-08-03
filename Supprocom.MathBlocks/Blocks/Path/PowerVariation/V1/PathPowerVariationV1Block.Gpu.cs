namespace Supprocom.MathBlocks.Gpu;

internal static class PathPowerVariationV1BlockGpu
{
    internal const string Identity = "path.power-variation@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 21);
}
