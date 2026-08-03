namespace Supprocom.MathBlocks.Gpu;

internal static class CombinatoricsFactorialV1BlockGpu
{
    internal const string Identity = "combinatorics.factorial@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 2);
}
