namespace Supprocom.MathBlocks.Gpu;

internal static class CooperativeShapleyValuesV1BlockGpu
{
    internal const string Identity = "cooperative.shapley-values@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 3);
}
