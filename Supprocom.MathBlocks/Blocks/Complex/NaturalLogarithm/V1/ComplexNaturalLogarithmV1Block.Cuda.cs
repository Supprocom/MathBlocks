namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexNaturalLogarithmV1BlockCuda
{
    internal const string Identity = "complex.natural-logarithm@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 8);
}
