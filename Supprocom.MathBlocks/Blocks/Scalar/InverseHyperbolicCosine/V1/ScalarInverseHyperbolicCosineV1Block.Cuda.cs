namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarInverseHyperbolicCosineV1BlockCuda
{
    internal const string Identity = "scalar.inverse-hyperbolic-cosine@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 32);
}
