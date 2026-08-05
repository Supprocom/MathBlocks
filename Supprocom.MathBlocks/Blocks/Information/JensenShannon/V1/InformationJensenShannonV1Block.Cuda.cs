namespace Supprocom.MathBlocks.Cuda;

internal static class InformationJensenShannonV1BlockCuda
{
    internal const string Identity = "information.jensen-shannon@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Probability, 10);
}
