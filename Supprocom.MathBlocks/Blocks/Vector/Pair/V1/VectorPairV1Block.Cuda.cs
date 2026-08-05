namespace Supprocom.MathBlocks.Cuda;

internal static class VectorPairV1BlockCuda
{
    internal const string Identity = "vector.pair@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 30);
}
