namespace Supprocom.MathBlocks.Cuda;

internal static class VectorSubtractV1BlockCuda
{
    internal const string Identity = "vector.subtract@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 47);
}
