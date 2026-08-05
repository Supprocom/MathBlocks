namespace Supprocom.MathBlocks.Cuda;

internal static class BooleanXorV1BlockCuda
{
    internal const string Identity = "boolean.xor@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 52);
}
