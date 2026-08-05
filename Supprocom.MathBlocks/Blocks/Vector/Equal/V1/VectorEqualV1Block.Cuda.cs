namespace Supprocom.MathBlocks.Cuda;

internal static class VectorEqualV1BlockCuda
{
    internal const string Identity = "vector.equal@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 11);
}
