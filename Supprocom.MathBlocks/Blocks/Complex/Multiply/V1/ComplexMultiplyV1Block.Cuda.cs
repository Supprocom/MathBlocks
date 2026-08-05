namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexMultiplyV1BlockCuda
{
    internal const string Identity = "complex.multiply@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 7);
}
