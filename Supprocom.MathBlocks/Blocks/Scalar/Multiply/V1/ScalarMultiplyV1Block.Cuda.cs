namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarMultiplyV1BlockCuda
{
    internal const string Identity = "scalar.multiply@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 2);
}
