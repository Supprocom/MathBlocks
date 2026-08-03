namespace Supprocom.MathBlocks.Gpu;

internal static class ShapeIsCompletelyMonotoneV1BlockGpu
{
    internal const string Identity = "shape.is-completely-monotone@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 14);
}
