namespace Supprocom.MathBlocks.Cuda;

internal static class ShapeLeastConcaveMajorantV1BlockCuda
{
    internal const string Identity = "shape.least-concave-majorant@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 16);
}
