namespace Supprocom.MathBlocks.Cuda;

internal static class VectorLinspaceV1BlockCuda
{
    internal const string Identity = "vector.linspace@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 21);
}
