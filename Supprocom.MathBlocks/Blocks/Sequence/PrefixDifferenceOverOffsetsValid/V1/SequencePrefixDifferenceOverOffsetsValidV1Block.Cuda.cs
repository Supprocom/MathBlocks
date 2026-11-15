namespace Supprocom.MathBlocks.Cuda;

internal static class SequencePrefixDifferenceOverOffsetsValidV1BlockCuda
{
    internal const string Identity = "sequence.prefix-difference-over-offsets-valid@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 44);
}
