namespace Supprocom.MathBlocks.Cuda;

internal static class BooleanVectorAndV1BlockCuda
{
    internal const string Identity = "boolean-vector.and@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 51);
}
