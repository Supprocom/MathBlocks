namespace Supprocom.MathBlocks.Gpu;

internal static class PointSetToMatrixV1BlockGpu
{
    internal const string Identity = "point-set.to-matrix@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 20);
}
