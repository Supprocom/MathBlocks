namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarArcTangentV1BlockCuda
{
    internal const string Identity = "scalar.arc-tangent@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 26);
}
