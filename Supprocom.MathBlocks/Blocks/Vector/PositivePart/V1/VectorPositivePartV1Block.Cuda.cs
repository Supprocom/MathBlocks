namespace Supprocom.MathBlocks.Cuda;

internal static class VectorPositivePartV1BlockCuda
{
    internal const string Identity = "vector.positive-part@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 31);
}
