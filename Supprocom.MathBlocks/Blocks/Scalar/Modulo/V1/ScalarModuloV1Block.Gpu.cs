namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarModuloV1BlockGpu
{
    internal const string Identity = "scalar.modulo@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 38);
}
