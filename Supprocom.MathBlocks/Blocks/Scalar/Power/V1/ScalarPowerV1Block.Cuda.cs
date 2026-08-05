namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarPowerV1BlockCuda
{
    internal const string Identity = "scalar.power@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 16);
}
