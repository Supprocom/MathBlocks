namespace Supprocom.MathBlocks.Cuda;

internal static class VectorAppendV1BlockCuda
{
    internal const string Identity = "vector.append@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 3);
}
