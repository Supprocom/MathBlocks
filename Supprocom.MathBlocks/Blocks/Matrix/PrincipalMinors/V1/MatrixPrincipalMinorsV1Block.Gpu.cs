namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixPrincipalMinorsV1BlockGpu
{
    internal const string Identity = "matrix.principal-minors@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 37);
}
