namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarInverseHyperbolicTangentV1BlockCuda
{
    internal const string Identity = "scalar.inverse-hyperbolic-tangent@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 33);
}
