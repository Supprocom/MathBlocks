namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarNaturalLogarithmV1BlockCuda
{
    internal const string Identity = "scalar.natural-logarithm@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 18);
}
