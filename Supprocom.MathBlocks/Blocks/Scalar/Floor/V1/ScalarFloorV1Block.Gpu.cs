namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarFloorV1BlockGpu
{
    internal const string Identity = "scalar.floor@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 34);
}
