namespace Supprocom.MathBlocks.Cuda;

internal static class VectorGeometricMeanV1BlockCuda
{
    internal const string Identity = "vector.geometric-mean@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 14);
}
