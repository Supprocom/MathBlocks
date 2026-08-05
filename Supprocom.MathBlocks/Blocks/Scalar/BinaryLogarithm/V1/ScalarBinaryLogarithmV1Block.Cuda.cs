namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarBinaryLogarithmV1BlockCuda
{
    internal const string Identity = "scalar.binary-logarithm@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 19);
}
