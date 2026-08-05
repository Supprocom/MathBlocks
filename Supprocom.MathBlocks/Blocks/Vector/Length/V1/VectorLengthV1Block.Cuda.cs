namespace Supprocom.MathBlocks.Cuda;

internal static class VectorLengthV1BlockCuda
{
    internal const string Identity = "vector.length@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 19);
}
