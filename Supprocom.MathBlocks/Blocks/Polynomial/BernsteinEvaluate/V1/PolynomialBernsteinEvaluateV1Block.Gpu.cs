namespace Supprocom.MathBlocks.Gpu;

internal static class PolynomialBernsteinEvaluateV1BlockGpu
{
    internal const string Identity = "polynomial.bernstein-evaluate@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 17);
}
