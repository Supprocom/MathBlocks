namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarSelectV1BlockCuda
{
    internal const string Identity = "scalar.select@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 54);
}
