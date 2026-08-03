namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarCubeV1BlockGpu
{
    internal const string Identity = "scalar.cube@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 13);
}
