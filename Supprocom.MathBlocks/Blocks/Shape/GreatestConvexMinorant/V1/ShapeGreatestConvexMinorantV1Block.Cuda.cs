namespace Supprocom.MathBlocks.Cuda;

internal static class ShapeGreatestConvexMinorantV1BlockCuda
{
    internal const string Identity = "shape.greatest-convex-minorant@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 13);
}
