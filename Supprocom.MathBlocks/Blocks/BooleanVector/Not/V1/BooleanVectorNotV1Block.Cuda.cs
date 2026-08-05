namespace Supprocom.MathBlocks.Cuda;

internal static class BooleanVectorNotV1BlockCuda
{
    internal const string Identity = "boolean-vector.not@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 53);
}
