namespace Supprocom.MathBlocks.Cuda;

internal static class PathQuadraticVariationV1BlockCuda
{
    internal const string Identity = "path.quadratic-variation@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 22);
}
