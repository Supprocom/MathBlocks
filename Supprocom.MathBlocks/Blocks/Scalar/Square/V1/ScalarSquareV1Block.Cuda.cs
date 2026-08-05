namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarSquareV1BlockCuda
{
    internal const string Identity = "scalar.square@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 12);
}
