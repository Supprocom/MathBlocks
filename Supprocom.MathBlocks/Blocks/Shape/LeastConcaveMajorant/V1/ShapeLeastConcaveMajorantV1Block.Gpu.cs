namespace Supprocom.MathBlocks.Gpu;

internal static class ShapeLeastConcaveMajorantV1BlockGpu
{
    internal const string Identity = "shape.least-concave-majorant@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 16);
}
