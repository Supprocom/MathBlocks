namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarDivideV1BlockGpu
{
    internal const string Identity = "scalar.divide@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 3);
}
