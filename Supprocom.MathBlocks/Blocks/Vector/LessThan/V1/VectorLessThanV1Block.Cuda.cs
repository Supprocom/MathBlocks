namespace Supprocom.MathBlocks.Cuda;

internal static class VectorLessThanV1BlockCuda
{
    internal const string Identity = "vector.less-than@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 20);
}
