namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarFloorV1BlockCuda
{
    internal const string Identity = "scalar.floor@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 34);
}
