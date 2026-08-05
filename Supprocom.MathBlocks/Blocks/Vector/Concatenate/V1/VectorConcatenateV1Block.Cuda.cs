namespace Supprocom.MathBlocks.Cuda;

internal static class VectorConcatenateV1BlockCuda
{
    internal const string Identity = "vector.concatenate@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 6);
}
