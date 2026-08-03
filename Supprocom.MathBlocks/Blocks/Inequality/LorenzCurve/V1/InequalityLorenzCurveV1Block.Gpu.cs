namespace Supprocom.MathBlocks.Gpu;

internal static class InequalityLorenzCurveV1BlockGpu
{
    internal const string Identity = "inequality.lorenz-curve@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Advanced, 7);
}
