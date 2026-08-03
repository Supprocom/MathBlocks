namespace Supprocom.MathBlocks.Gpu;

internal static class SpecialErrorFunctionV1BlockGpu
{
    internal const string Identity = "special.error-function@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 43);
}
