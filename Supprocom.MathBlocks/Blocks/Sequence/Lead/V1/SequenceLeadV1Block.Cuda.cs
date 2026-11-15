namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceLeadV1BlockCuda
{
    internal const string Identity = "sequence.lead@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 33);
}
