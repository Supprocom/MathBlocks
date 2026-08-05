namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarCubeRootV1BlockCuda
{
    internal const string Identity = "scalar.cube-root@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 15);
}
