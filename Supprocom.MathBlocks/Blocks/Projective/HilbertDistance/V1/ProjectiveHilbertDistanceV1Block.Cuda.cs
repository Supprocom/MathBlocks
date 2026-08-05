namespace Supprocom.MathBlocks.Cuda;

internal static class ProjectiveHilbertDistanceV1BlockCuda
{
    internal const string Identity = "projective.hilbert-distance@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 12);
}
