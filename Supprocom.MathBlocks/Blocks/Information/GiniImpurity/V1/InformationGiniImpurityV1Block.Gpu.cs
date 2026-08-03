namespace Supprocom.MathBlocks.Gpu;

internal static class InformationGiniImpurityV1BlockGpu
{
    internal const string Identity = "information.gini-impurity@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 8);
}
