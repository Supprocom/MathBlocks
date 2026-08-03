namespace Supprocom.MathBlocks.Gpu;

internal static class ShapeIsLogConcaveV1BlockGpu
{
    internal const string Identity = "shape.is-log-concave@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 15);
}
