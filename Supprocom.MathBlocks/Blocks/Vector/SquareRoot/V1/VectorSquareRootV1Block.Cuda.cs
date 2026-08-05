namespace Supprocom.MathBlocks.Cuda;

internal static class VectorSquareRootV1BlockCuda
{
    internal const string Identity = "vector.square-root@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 44);
}
