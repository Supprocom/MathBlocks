namespace Supprocom.MathBlocks.Cuda;

internal static class PathRecurrenceRateV1BlockCuda
{
    internal const string Identity = "path.recurrence-rate@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 23);
}
