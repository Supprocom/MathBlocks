namespace Supprocom.MathBlocks.Cuda;

internal static class BooleanVectorTrueIndicesV1BlockCuda
{
    internal const string Identity = "boolean-vector.true-indices@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 56);
}
