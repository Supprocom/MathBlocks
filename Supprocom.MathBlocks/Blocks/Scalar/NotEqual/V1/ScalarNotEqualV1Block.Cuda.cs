namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarNotEqualV1BlockCuda
{
    internal const string Identity = "scalar.not-equal@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 45);
}
