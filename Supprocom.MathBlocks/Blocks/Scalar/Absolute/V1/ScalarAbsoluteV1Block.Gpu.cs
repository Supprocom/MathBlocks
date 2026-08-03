namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarAbsoluteV1BlockGpu
{
    internal const string Identity = "scalar.absolute@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 5);
}
