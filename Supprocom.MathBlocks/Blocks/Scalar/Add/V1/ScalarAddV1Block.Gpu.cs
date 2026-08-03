namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarAddV1BlockGpu
{
    internal const string Identity = "scalar.add@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 0);
}
