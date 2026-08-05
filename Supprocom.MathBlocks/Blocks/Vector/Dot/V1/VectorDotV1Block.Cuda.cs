namespace Supprocom.MathBlocks.Cuda;

internal static class VectorDotV1BlockCuda
{
    internal const string Identity = "vector.dot@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 10);
}
