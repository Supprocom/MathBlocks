namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarLogOnePlusV1BlockCuda
{
    internal const string Identity = "scalar.log-one-plus@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 42);
}
