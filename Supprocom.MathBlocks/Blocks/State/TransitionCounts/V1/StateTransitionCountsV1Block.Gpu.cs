namespace Supprocom.MathBlocks.Gpu;

internal static class StateTransitionCountsV1BlockGpu
{
    internal const string Identity = "state.transition-counts@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 32);
}
