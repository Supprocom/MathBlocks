namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarMaximumV1BlockCuda
{
    internal const string Identity = "scalar.maximum@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 9);
}
