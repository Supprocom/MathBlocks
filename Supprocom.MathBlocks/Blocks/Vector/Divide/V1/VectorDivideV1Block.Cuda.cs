namespace Supprocom.MathBlocks.Cuda;

internal static class VectorDivideV1BlockCuda
{
    internal const string Identity = "vector.divide@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 9);
}
