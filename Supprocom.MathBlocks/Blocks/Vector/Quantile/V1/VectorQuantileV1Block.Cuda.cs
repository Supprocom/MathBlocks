namespace Supprocom.MathBlocks.Cuda;

internal static class VectorQuantileV1BlockCuda
{
    internal const string Identity = "vector.quantile@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 35);
}
