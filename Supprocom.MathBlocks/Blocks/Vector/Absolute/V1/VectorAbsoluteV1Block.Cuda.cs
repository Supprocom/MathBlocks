namespace Supprocom.MathBlocks.Cuda;

internal static class VectorAbsoluteV1BlockCuda
{
    internal const string Identity = "vector.absolute@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 0);
}
