namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarSubtractV1BlockCuda
{
    internal const string Identity = "scalar.subtract@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 1);
}
