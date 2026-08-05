namespace Supprocom.MathBlocks.Cuda;

internal static class VectorL2NormV1BlockCuda
{
    internal const string Identity = "vector.l2-norm@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 18);
}
