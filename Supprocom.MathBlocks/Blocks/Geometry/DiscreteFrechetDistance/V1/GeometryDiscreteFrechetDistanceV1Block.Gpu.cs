namespace Supprocom.MathBlocks.Gpu;

internal static class GeometryDiscreteFrechetDistanceV1BlockGpu
{
    internal const string Identity = "geometry.discrete-frechet-distance@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Geometry, 7);
}
