namespace Supprocom.MathBlocks.Cuda;

internal static class VectorMultiplyV1BlockCuda
{
    internal const string Identity = "vector.multiply@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 26);
}
