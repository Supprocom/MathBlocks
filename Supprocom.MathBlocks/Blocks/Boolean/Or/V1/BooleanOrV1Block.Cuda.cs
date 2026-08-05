namespace Supprocom.MathBlocks.Cuda;

internal static class BooleanOrV1BlockCuda
{
    internal const string Identity = "boolean.or@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 51);
}
