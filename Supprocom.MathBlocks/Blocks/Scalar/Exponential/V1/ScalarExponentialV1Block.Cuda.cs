namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarExponentialV1BlockCuda
{
    internal const string Identity = "scalar.exponential@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 17);
}
