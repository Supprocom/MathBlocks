namespace Supprocom.MathBlocks.Gpu;

internal static class TransformWalshHadamardV1BlockGpu
{
    internal const string Identity = "transform.walsh-hadamard@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 12);
}
