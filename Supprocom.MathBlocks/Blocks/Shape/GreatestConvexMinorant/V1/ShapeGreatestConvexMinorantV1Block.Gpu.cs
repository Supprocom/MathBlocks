namespace Supprocom.MathBlocks.Gpu;

internal static class ShapeGreatestConvexMinorantV1BlockGpu
{
    internal const string Identity = "shape.greatest-convex-minorant@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 13);
}
