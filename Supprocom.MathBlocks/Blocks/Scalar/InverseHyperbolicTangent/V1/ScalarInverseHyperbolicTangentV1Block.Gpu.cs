namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarInverseHyperbolicTangentV1BlockGpu
{
    internal const string Identity = "scalar.inverse-hyperbolic-tangent@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 33);
}
