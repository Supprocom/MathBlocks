namespace Supprocom.MathBlocks.Cuda;

internal static class VectorScaleV1BlockCuda
{
    internal const string Identity = "vector.scale@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 39);
}
