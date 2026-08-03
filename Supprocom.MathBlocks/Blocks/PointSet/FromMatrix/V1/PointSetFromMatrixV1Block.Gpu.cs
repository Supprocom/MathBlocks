namespace Supprocom.MathBlocks.Gpu;

internal static class PointSetFromMatrixV1BlockGpu
{
    internal const string Identity = "point-set.from-matrix@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 19);
}
