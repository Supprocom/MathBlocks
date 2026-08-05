namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexSquareRootV1BlockCuda
{
    internal const string Identity = "complex.square-root@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 12);
}
