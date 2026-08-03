namespace Supprocom.MathBlocks.Gpu;

internal static class MatrixSpectralNormV1BlockGpu
{
    internal const string Identity = "matrix.spectral-norm@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Matrix, 42);
}
