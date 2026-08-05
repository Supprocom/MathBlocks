namespace Supprocom.MathBlocks.Cuda;

internal static class InformationGiniImpurityV1BlockCuda
{
    internal const string Identity = "information.gini-impurity@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 8);
}
