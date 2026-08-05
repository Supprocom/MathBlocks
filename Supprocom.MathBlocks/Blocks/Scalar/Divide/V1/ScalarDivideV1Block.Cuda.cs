namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarDivideV1BlockCuda
{
    internal const string Identity = "scalar.divide@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 3);
}
