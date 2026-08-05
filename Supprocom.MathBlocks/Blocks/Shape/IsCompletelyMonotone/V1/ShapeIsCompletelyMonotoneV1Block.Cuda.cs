namespace Supprocom.MathBlocks.Cuda;

internal static class ShapeIsCompletelyMonotoneV1BlockCuda
{
    internal const string Identity = "shape.is-completely-monotone@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 14);
}
