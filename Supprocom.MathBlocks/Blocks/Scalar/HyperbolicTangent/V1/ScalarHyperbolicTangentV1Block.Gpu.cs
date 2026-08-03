namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarHyperbolicTangentV1BlockGpu
{
    internal const string Identity = "scalar.hyperbolic-tangent@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 30);
}
