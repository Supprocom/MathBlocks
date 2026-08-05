namespace Supprocom.MathBlocks.Cuda;

internal static class CooperativeShapleyValuesV1BlockCuda
{
    internal const string Identity = "cooperative.shapley-values@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 3);
}
