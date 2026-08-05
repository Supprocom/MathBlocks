namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarCosineV1BlockCuda
{
    internal const string Identity = "scalar.cosine@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 22);
}
