namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarLogisticV1BlockCuda
{
    internal const string Identity = "scalar.logistic@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 39);
}
