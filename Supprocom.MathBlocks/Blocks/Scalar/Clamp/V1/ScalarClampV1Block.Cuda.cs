namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarClampV1BlockCuda
{
    internal const string Identity = "scalar.clamp@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 10);
}
