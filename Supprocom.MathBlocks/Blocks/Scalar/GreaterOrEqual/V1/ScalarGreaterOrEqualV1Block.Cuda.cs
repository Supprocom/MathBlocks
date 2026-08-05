namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarGreaterOrEqualV1BlockCuda
{
    internal const string Identity = "scalar.greater-or-equal@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 49);
}
