namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarTruncateV1BlockCuda
{
    internal const string Identity = "scalar.truncate@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 37);
}
