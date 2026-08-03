namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarTangentV1BlockGpu
{
    internal const string Identity = "scalar.tangent@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 23);
}
