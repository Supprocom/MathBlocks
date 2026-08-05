namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexAddV1BlockCuda
{
    internal const string Identity = "complex.add@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 0);
}
