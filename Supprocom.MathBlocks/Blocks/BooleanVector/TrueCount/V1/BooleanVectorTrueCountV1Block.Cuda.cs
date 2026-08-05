namespace Supprocom.MathBlocks.Cuda;

internal static class BooleanVectorTrueCountV1BlockCuda
{
    internal const string Identity = "boolean-vector.true-count@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 55);
}
