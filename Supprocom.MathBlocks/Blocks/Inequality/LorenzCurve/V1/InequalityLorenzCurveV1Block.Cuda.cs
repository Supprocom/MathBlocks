namespace Supprocom.MathBlocks.Cuda;

internal static class InequalityLorenzCurveV1BlockCuda
{
    internal const string Identity = "inequality.lorenz-curve@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 7);
}
