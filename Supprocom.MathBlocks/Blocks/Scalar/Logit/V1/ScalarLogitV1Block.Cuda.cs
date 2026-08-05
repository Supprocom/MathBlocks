namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarLogitV1BlockCuda
{
    internal const string Identity = "scalar.logit@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 40);
}
