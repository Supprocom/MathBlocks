namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarCommonLogarithmV1BlockCuda
{
    internal const string Identity = "scalar.common-logarithm@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 20);
}
