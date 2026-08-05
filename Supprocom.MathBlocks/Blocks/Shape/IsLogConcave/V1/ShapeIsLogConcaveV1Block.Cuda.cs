namespace Supprocom.MathBlocks.Cuda;

internal static class ShapeIsLogConcaveV1BlockCuda
{
    internal const string Identity = "shape.is-log-concave@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 15);
}
