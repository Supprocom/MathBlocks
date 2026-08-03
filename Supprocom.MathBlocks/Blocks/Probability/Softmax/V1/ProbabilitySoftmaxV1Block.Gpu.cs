namespace Supprocom.MathBlocks.Gpu;

internal static class ProbabilitySoftmaxV1BlockGpu
{
    internal const string Identity = "probability.softmax@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 27);
}
