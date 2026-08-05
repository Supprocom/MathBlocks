namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarArcSineV1BlockCuda
{
    internal const string Identity = "scalar.arc-sine@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 24);
}
