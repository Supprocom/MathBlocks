namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexSubtractV1BlockCuda
{
    internal const string Identity = "complex.subtract@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 13);
}
