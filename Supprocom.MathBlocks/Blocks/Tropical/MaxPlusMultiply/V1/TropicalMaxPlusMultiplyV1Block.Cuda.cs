namespace Supprocom.MathBlocks.Cuda;

internal static class TropicalMaxPlusMultiplyV1BlockCuda
{
    internal const string Identity = "tropical.max-plus-multiply@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Transport, 9);
}
