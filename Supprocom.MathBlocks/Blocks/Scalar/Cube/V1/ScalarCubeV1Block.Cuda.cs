namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarCubeV1BlockCuda
{
    internal const string Identity = "scalar.cube@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 13);
}
