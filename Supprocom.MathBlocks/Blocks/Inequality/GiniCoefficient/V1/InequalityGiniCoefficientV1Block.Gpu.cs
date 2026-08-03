namespace Supprocom.MathBlocks.Gpu;

internal static class InequalityGiniCoefficientV1BlockGpu
{
    internal const string Identity = "inequality.gini-coefficient@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 6);
}
