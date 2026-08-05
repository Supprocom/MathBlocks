namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexVectorImaginaryV1BlockCuda
{
    internal const string Identity = "complex-vector.imaginary@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 15);
}
