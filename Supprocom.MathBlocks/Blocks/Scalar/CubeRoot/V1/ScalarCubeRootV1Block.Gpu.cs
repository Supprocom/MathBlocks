namespace Supprocom.MathBlocks.Gpu;

internal static class ScalarCubeRootV1BlockGpu
{
    internal const string Identity = "scalar.cube-root@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 15);
}
