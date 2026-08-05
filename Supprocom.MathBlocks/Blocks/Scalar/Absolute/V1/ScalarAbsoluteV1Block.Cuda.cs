namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarAbsoluteV1BlockCuda
{
    internal const string Identity = "scalar.absolute@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 5);
}
