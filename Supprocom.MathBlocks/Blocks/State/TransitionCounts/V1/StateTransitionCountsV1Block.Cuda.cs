namespace Supprocom.MathBlocks.Cuda;

internal static class StateTransitionCountsV1BlockCuda
{
    internal const string Identity = "state.transition-counts@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 32);
}
