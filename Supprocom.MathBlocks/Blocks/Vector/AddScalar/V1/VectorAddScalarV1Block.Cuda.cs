namespace Supprocom.MathBlocks.Cuda;

internal static class VectorAddScalarV1BlockCuda
{
    internal const string Identity = "vector.add-scalar@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 1);
}
