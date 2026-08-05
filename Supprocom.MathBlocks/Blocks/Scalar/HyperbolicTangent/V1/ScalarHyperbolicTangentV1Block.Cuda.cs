namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarHyperbolicTangentV1BlockCuda
{
    internal const string Identity = "scalar.hyperbolic-tangent@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 30);
}
