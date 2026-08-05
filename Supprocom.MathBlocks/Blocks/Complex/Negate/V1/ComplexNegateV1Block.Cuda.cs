namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexNegateV1BlockCuda
{
    internal const string Identity = "complex.negate@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 9);
}
