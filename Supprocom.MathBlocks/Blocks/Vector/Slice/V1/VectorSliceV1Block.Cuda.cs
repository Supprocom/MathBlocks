namespace Supprocom.MathBlocks.Cuda;

internal static class VectorSliceV1BlockCuda
{
    internal const string Identity = "vector.slice@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 42);
}
