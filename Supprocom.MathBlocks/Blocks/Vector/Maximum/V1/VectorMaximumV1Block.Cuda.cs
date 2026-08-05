namespace Supprocom.MathBlocks.Cuda;

internal static class VectorMaximumV1BlockCuda
{
    internal const string Identity = "vector.maximum@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 22);
}
