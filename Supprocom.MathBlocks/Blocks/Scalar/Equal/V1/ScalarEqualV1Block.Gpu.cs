namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarEqualV1BlockGpu
{
    internal const string Identity = "scalar.equal@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 44);
}
