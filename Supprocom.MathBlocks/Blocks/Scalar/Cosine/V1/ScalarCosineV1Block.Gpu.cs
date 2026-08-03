namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarCosineV1BlockGpu
{
    internal const string Identity = "scalar.cosine@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 22);
}
