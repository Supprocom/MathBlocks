namespace Supprocom.MathBlocks.Gpu;

internal static class SequenceConvolutionV1BlockGpu
{
    internal const string Identity = "sequence.convolution@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 0);
}
