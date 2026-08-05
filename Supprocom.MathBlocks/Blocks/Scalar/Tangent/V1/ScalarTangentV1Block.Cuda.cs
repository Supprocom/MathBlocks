namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarTangentV1BlockCuda
{
    internal const string Identity = "scalar.tangent@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 23);
}
