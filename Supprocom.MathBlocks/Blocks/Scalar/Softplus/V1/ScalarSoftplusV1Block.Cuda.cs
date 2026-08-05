namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarSoftplusV1BlockCuda
{
    internal const string Identity = "scalar.softplus@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 41);
}
