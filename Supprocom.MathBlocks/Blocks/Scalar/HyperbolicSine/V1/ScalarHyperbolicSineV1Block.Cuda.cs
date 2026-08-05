namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarHyperbolicSineV1BlockCuda
{
    internal const string Identity = "scalar.hyperbolic-sine@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 28);
}
