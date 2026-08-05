namespace Supprocom.MathBlocks.Cuda;

internal static class SurvivalDiscreteHazardV1BlockCuda
{
    internal const string Identity = "survival.discrete-hazard@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 17);
}
