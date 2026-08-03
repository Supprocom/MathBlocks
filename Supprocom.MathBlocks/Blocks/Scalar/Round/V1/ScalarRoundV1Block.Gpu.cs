namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarRoundV1BlockGpu
{
    internal const string Identity = "scalar.round@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 36);
}
