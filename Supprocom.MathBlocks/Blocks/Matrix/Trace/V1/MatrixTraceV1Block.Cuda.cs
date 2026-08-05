namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixTraceV1BlockCuda
{
    internal const string Identity = "matrix.trace@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Matrix, 24);
}
