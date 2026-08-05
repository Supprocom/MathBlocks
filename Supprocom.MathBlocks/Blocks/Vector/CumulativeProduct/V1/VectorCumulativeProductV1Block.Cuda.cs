namespace Supprocom.MathBlocks.Cuda;

internal static class VectorCumulativeProductV1BlockCuda
{
    internal const string Identity = "vector.cumulative-product@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 7);
}
