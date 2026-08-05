namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceDifferenceV1BlockCuda
{
    internal const string Identity = "sequence.difference@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 1);
}
