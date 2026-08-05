namespace Supprocom.MathBlocks.Cuda;

internal static class VectorNormalizeL1V1BlockCuda
{
    internal const string Identity = "vector.normalize-l1@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 28);
}
