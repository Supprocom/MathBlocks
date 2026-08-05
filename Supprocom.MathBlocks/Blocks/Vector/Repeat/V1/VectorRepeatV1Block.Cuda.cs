namespace Supprocom.MathBlocks.Cuda;

internal static class VectorRepeatV1BlockCuda
{
    internal const string Identity = "vector.repeat@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 37);
}
