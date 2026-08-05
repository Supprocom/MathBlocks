namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexVectorCreateV1BlockCuda
{
    internal const string Identity = "complex-vector.create@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 14);
}
