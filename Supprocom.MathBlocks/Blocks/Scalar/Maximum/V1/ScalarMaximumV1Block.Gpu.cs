namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarMaximumV1BlockGpu
{
    internal const string Identity = "scalar.maximum@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 9);
}
