namespace Supprocom.MathBlocks.Cuda;

internal static class VectorCumulativeSumV1BlockCuda
{
    internal const string Identity = "vector.cumulative-sum@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 8);
}
