namespace Supprocom.MathBlocks.Cuda;

internal static class BooleanVectorAnyV1BlockCuda
{
    internal const string Identity = "boolean-vector.any@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 52);
}
