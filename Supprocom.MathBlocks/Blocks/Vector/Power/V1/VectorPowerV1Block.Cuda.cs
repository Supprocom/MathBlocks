namespace Supprocom.MathBlocks.Cuda;

internal static class VectorPowerV1BlockCuda
{
    internal const string Identity = "vector.power@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 32);
}
