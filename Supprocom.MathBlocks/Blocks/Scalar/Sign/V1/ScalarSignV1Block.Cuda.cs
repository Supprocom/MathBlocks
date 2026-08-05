namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarSignV1BlockCuda
{
    internal const string Identity = "scalar.sign@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 6);
}
