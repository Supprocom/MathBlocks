namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexMagnitudeV1BlockCuda
{
    internal const string Identity = "complex.magnitude@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 6);
}
