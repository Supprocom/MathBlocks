namespace Supprocom.MathBlocks.Cuda;

internal static class SpecialErrorFunctionV1BlockCuda
{
    internal const string Identity = "special.error-function@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 43);
}
