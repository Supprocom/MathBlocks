namespace Supprocom.MathBlocks.Cuda;

internal static class TransformWalshHadamardV1BlockCuda
{
    internal const string Identity = "transform.walsh-hadamard@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 12);
}
