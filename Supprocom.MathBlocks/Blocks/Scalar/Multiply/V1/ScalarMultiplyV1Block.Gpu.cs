namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarMultiplyV1BlockGpu
{
    internal const string Identity = "scalar.multiply@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 2);
}
