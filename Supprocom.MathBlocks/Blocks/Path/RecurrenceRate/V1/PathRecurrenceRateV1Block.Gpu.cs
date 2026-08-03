namespace Supprocom.MathBlocks.Gpu;

internal static class PathRecurrenceRateV1BlockGpu
{
    internal const string Identity = "path.recurrence-rate@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 23);
}
