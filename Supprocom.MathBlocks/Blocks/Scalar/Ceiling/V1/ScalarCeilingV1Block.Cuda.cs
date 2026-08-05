namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarCeilingV1BlockCuda
{
    internal const string Identity = "scalar.ceiling@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 35);
}
