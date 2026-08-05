namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarSquareRootV1BlockCuda
{
    internal const string Identity = "scalar.square-root@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 14);
}
