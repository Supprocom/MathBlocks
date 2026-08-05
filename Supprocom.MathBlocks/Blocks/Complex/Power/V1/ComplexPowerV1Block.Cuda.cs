namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexPowerV1BlockCuda
{
    internal const string Identity = "complex.power@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 11);
}
