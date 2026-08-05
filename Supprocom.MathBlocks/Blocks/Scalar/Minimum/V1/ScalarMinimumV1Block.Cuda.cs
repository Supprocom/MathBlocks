namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarMinimumV1BlockCuda
{
    internal const string Identity = "scalar.minimum@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 8);
}
