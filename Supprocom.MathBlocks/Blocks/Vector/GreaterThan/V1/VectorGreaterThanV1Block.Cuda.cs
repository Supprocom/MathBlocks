namespace Supprocom.MathBlocks.Cuda;

internal static class VectorGreaterThanV1BlockCuda
{
    internal const string Identity = "vector.greater-than@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 15);
}
