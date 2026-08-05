namespace Supprocom.MathBlocks.Cuda;

internal static class VectorPrependV1BlockCuda
{
    internal const string Identity = "vector.prepend@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 33);
}
