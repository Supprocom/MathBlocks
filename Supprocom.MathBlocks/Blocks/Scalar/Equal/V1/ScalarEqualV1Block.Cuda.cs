namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarEqualV1BlockCuda
{
    internal const string Identity = "scalar.equal@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 44);
}
