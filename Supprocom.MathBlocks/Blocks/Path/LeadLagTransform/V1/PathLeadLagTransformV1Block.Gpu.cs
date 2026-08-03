namespace Supprocom.MathBlocks.Gpu;

internal static class PathLeadLagTransformV1BlockGpu
{
    internal const string Identity = "path.lead-lag-transform@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 17);
}
