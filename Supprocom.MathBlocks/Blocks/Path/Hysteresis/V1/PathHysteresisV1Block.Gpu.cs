namespace Supprocom.MathBlocks.Gpu;

internal static class PathHysteresisV1BlockGpu
{
    internal const string Identity = "path.hysteresis@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 16);
}
