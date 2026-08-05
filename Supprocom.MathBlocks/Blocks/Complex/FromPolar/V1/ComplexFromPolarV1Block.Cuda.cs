namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexFromPolarV1BlockCuda
{
    internal const string Identity = "complex.from-polar@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 5);
}
