namespace Supprocom.MathBlocks.Cuda;

internal static class VectorArgMinimumV1BlockCuda
{
    internal const string Identity = "vector.arg-minimum@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 5);
}
