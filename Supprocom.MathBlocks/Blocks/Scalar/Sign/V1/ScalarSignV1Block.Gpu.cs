namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarSignV1BlockGpu
{
    internal const string Identity = "scalar.sign@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 6);
}
