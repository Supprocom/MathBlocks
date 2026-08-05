namespace Supprocom.MathBlocks.Cuda;

internal static class VectorNormalizeL2V1BlockCuda
{
    internal const string Identity = "vector.normalize-l2@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 29);
}
