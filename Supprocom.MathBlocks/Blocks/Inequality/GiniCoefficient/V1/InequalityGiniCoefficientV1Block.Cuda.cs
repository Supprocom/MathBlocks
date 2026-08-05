namespace Supprocom.MathBlocks.Cuda;

internal static class InequalityGiniCoefficientV1BlockCuda
{
    internal const string Identity = "inequality.gini-coefficient@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 6);
}
