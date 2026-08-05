namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarLessThanV1BlockCuda
{
    internal const string Identity = "scalar.less-than@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 46);
}
