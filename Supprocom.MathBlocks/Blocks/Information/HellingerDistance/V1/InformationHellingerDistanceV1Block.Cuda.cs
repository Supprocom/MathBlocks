namespace Supprocom.MathBlocks.Cuda;

internal static class InformationHellingerDistanceV1BlockCuda
{
    internal const string Identity = "information.hellinger-distance@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 9);
}
