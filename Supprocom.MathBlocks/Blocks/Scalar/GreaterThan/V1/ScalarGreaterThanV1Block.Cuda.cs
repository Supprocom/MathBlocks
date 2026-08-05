namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarGreaterThanV1BlockCuda
{
    internal const string Identity = "scalar.greater-than@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 48);
}
