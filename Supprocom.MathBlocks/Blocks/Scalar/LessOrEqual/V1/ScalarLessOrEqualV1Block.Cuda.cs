namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarLessOrEqualV1BlockCuda
{
    internal const string Identity = "scalar.less-or-equal@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 47);
}
