namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarNegateV1BlockGpu
{
    internal const string Identity = "scalar.negate@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 4);
}
