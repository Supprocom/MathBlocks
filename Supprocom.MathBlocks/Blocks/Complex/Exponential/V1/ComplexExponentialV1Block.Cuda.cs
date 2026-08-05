namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexExponentialV1BlockCuda
{
    internal const string Identity = "complex.exponential@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 4);
}
