namespace Supprocom.MathBlocks.Gpu;

internal static class BooleanNotV1BlockGpu
{
    internal const string Identity = "boolean.not@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Scalar, 53);
}
