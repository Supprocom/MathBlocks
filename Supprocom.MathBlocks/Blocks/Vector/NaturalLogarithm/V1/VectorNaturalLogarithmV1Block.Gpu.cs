namespace Supprocom.MathBlocks.Gpu;

internal static class VectorNaturalLogarithmV1BlockGpu
{
    internal const string Identity = "vector.natural-logarithm@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Vector, 27);
}
