namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarSineV1BlockCuda
{
    internal const string Identity = "scalar.sine@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 21);
}
