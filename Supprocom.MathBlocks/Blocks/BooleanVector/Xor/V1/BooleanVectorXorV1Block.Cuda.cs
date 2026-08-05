namespace Supprocom.MathBlocks.Cuda;

internal static class BooleanVectorXorV1BlockCuda
{
    internal const string Identity = "boolean-vector.xor@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 57);
}
