namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarSelectV1BlockGpu
{
    internal const string Identity = "scalar.select@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 54);
}
