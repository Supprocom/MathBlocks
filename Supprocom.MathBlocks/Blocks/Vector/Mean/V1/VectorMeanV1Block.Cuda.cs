namespace Supprocom.MathBlocks.Cuda;

internal static class VectorMeanV1BlockCuda
{
    internal const string Identity = "vector.mean@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 23);
}
