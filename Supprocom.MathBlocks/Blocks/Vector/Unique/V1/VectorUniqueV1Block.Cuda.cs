namespace Supprocom.MathBlocks.Cuda;

internal static class VectorUniqueV1BlockCuda
{
    internal const string Identity = "vector.unique@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 49);
}
