namespace Supprocom.MathBlocks.Cuda;

internal static class TropicalMinPlusMultiplyV1BlockCuda
{
    internal const string Identity = "tropical.min-plus-multiply@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Transport, 10);
}
