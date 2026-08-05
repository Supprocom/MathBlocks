namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexConjugateV1BlockCuda
{
    internal const string Identity = "complex.conjugate@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 1);
}
