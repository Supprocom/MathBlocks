namespace Supprocom.MathBlocks.Cuda;

internal static class SequenceRollingStandardDeviationV1BlockCuda
{
    internal const string Identity = "sequence.rolling-standard-deviation@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 8);
}
