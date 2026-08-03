namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarSquareRootV1BlockGpu
{
    internal const string Identity = "scalar.square-root@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 14);
}
