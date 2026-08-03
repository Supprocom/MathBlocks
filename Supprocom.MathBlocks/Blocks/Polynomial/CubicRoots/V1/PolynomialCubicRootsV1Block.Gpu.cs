namespace Supprocom.MathBlocks.Gpu;

internal static class PolynomialCubicRootsV1BlockGpu
{
    internal const string Identity = "polynomial.cubic-roots@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 18);
}
