namespace Supprocom.MathBlocks.Gpu;

internal static class VectorGeometricMeanV1BlockGpu
{
    internal const string Identity = "vector.geometric-mean@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 14);
}
