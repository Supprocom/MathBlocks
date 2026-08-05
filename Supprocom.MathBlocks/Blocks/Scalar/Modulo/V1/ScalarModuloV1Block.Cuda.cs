namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarModuloV1BlockCuda
{
    internal const string Identity = "scalar.modulo@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 38);
}
