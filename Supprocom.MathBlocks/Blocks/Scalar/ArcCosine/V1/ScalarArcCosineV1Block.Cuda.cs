namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarArcCosineV1BlockCuda
{
    internal const string Identity = "scalar.arc-cosine@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 25);
}
