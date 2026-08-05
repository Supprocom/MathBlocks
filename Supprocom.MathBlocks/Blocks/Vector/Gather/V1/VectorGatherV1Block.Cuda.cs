namespace Supprocom.MathBlocks.Cuda;

internal static class VectorGatherV1BlockCuda
{
    internal const string Identity = "vector.gather@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 13);
}
