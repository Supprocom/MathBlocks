namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexVectorMagnitudeV1BlockCuda
{
    internal const string Identity = "complex-vector.magnitude@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 16);
}
