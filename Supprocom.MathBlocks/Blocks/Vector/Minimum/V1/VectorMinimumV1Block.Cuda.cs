namespace Supprocom.MathBlocks.Cuda;

internal static class VectorMinimumV1BlockCuda
{
    internal const string Identity = "vector.minimum@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 25);
}
