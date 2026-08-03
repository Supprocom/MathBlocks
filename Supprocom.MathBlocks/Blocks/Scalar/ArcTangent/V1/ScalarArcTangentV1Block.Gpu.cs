namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarArcTangentV1BlockGpu
{
    internal const string Identity = "scalar.arc-tangent@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 26);
}
