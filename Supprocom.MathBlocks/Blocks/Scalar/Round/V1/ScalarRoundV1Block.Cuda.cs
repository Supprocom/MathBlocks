namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarRoundV1BlockCuda
{
    internal const string Identity = "scalar.round@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 36);
}
