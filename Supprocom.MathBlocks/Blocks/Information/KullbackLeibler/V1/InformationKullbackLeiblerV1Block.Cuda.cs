namespace Supprocom.MathBlocks.Cuda;

internal static class InformationKullbackLeiblerV1BlockCuda
{
    internal const string Identity = "information.kullback-leibler@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 11);
}
