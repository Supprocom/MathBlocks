namespace Supprocom.MathBlocks.Cuda;

internal static class VectorSelectV1BlockCuda
{
    internal const string Identity = "vector.select@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 40);
}
