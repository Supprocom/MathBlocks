namespace Supprocom.MathBlocks.Cuda;

internal static class BooleanVectorOrV1BlockCuda
{
    internal const string Identity = "boolean-vector.or@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Vector, 54);
}
