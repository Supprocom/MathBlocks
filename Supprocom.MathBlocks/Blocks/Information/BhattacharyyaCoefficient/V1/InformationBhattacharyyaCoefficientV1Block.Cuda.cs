namespace Supprocom.MathBlocks.Cuda;

internal static class InformationBhattacharyyaCoefficientV1BlockCuda
{
    internal const string Identity = "information.bhattacharyya-coefficient@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 4);
}
