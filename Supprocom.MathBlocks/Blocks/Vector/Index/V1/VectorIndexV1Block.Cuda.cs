namespace Supprocom.MathBlocks.Cuda;

internal static class VectorIndexV1BlockCuda
{
    internal const string Identity = "vector.index@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 16);
}
