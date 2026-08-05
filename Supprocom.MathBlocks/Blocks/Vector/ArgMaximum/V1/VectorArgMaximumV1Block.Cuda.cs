namespace Supprocom.MathBlocks.Cuda;

internal static class VectorArgMaximumV1BlockCuda
{
    internal const string Identity = "vector.arg-maximum@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 4);
}
