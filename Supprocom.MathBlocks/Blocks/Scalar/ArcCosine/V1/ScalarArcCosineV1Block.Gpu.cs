namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarArcCosineV1BlockGpu
{
    internal const string Identity = "scalar.arc-cosine@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 25);
}
