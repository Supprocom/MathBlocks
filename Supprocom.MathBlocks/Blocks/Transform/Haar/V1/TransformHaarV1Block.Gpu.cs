namespace Supprocom.MathBlocks.Gpu;

internal static class TransformHaarV1BlockGpu
{
    internal const string Identity = "transform.haar@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 11);
}
