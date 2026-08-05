namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceConvolutionV1BlockCuda
{
    internal const string Identity = "sequence.convolution@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 0);
}
