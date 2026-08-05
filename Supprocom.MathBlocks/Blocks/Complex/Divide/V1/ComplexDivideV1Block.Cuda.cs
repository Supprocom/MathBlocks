namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexDivideV1BlockCuda
{
    internal const string Identity = "complex.divide@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 3);
}
