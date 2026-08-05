namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarInverseHyperbolicSineV1BlockCuda
{
    internal const string Identity = "scalar.inverse-hyperbolic-sine@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 31);
}
