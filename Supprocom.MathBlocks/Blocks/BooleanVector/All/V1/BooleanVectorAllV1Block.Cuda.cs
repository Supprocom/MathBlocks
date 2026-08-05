namespace Supprocom.MathBlocks.Cuda;

internal static class BooleanVectorAllV1BlockCuda
{
    internal const string Identity = "boolean-vector.all@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 50);
}
