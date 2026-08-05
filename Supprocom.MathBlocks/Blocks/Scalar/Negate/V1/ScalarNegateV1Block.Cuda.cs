namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarNegateV1BlockCuda
{
    internal const string Identity = "scalar.negate@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 4);
}
