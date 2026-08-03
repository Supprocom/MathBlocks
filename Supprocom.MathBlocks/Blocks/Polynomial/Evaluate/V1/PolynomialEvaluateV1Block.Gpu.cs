namespace Supprocom.MathBlocks.Gpu;

internal static class PolynomialEvaluateV1BlockGpu
{
    internal const string Identity = "polynomial.evaluate@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 21);
}
