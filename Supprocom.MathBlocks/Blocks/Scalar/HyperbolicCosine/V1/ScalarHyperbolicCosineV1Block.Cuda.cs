namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarHyperbolicCosineV1BlockCuda
{
    internal const string Identity = "scalar.hyperbolic-cosine@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 29);
}
