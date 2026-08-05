namespace Supprocom.MathBlocks.Cuda;

internal static class BooleanAndV1BlockCuda
{
    internal const string Identity = "boolean.and@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 50);
}
