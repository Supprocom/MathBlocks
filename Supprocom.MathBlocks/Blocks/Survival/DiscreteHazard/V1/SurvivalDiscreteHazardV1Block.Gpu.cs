namespace Supprocom.MathBlocks.Gpu;

internal static class SurvivalDiscreteHazardV1BlockGpu
{
    internal const string Identity = "survival.discrete-hazard@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 17);
}
