namespace Supprocom.MathBlocks.Cuda;

internal static class VectorExponentialV1BlockCuda
{
    internal const string Identity = "vector.exponential@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 12);
}
