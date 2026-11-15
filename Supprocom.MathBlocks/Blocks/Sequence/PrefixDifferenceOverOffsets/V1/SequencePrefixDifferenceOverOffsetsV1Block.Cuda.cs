namespace Supprocom.MathBlocks.Cuda;

internal static class SequencePrefixDifferenceOverOffsetsV1BlockCuda
{
    internal const string Identity = "sequence.prefix-difference-over-offsets@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 43);
}
