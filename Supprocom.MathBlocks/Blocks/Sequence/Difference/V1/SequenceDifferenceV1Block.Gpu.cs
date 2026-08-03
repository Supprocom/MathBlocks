namespace Supprocom.MathBlocks.Gpu;

internal static class SequenceDifferenceV1BlockGpu
{
    internal const string Identity = "sequence.difference@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 1);
}
