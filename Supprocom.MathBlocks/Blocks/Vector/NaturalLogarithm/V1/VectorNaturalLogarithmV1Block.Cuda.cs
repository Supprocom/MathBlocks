namespace Supprocom.MathBlocks.Cuda;

internal static class VectorNaturalLogarithmV1BlockCuda
{
    internal const string Identity = "vector.natural-logarithm@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 27);
}
