namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixIdentityV1BlockGpu
{
    internal const string Identity = "matrix.identity@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 12);
}
