namespace Supprocom.MathBlocks.Cuda;

internal static class VectorL1NormV1BlockCuda
{
    internal const string Identity = "vector.l1-norm@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 17);
}
