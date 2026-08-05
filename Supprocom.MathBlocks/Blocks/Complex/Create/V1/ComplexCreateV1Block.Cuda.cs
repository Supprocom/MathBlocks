namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexCreateV1BlockCuda
{
    internal const string Identity = "complex.create@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 2);
}
