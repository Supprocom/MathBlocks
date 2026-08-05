namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexPhaseV1BlockCuda
{
    internal const string Identity = "complex.phase@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 10);
}
