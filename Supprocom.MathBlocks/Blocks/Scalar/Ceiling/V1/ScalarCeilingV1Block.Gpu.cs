namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarCeilingV1BlockGpu
{
    internal const string Identity = "scalar.ceiling@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 35);
}
