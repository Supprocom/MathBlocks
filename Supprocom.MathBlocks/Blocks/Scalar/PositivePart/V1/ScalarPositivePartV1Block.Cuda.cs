namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarPositivePartV1BlockCuda
{
    internal const string Identity = "scalar.positive-part@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 7);
}
