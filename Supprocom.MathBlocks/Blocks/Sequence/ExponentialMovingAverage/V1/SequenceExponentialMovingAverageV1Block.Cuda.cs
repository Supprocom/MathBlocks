namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceExponentialMovingAverageV1BlockCuda
{
    internal const string Identity = "sequence.exponential-moving-average@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 2);
}
