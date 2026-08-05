namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarAddV1BlockCuda
{
    internal const string Identity = "scalar.add@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 0);
}
