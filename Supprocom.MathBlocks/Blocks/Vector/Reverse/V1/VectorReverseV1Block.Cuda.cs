namespace Supprocom.MathBlocks.Cuda;

internal static class VectorReverseV1BlockCuda
{
    internal const string Identity = "vector.reverse@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 38);
}
