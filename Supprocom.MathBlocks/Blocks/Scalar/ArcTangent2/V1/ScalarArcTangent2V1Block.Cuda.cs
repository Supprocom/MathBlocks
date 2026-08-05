namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarArcTangent2V1BlockCuda
{
    internal const string Identity = "scalar.arc-tangent-2@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Scalar, 27);
}
