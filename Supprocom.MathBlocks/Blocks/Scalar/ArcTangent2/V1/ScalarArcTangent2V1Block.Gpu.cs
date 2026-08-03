namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarArcTangent2V1BlockGpu
{
    internal const string Identity = "scalar.arc-tangent-2@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 27);
}
