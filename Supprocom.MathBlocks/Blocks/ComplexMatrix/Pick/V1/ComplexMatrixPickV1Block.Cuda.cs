namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexMatrixPickV1BlockCuda
{
    internal const string Identity = "complex-matrix.pick@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 18);
}
