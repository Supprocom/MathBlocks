namespace Supprocom.MathBlocks.Cuda;

internal static class VectorAddV1BlockCuda
{
    internal const string Identity = "vector.add@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 2);
}
