namespace Supprocom.MathBlocks.Cuda;

internal static class BooleanNotV1BlockCuda
{
    internal const string Identity = "boolean.not@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 53);
}
