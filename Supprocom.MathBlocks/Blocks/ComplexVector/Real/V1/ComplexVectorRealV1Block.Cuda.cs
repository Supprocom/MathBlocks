namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexVectorRealV1BlockCuda
{
    internal const string Identity = "complex-vector.real@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 17);
}
