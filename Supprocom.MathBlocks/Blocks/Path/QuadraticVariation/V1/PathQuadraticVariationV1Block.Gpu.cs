namespace Supprocom.MathBlocks.Gpu;

internal static class PathQuadraticVariationV1BlockGpu
{
    internal const string Identity = "path.quadratic-variation@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.SequencePath, 22);
}
