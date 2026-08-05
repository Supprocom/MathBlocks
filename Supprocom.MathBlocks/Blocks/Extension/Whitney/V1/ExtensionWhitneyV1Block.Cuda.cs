namespace Supprocom.MathBlocks.Cuda;

internal static class ExtensionWhitneyV1BlockCuda
{
    internal const string Identity = "extension.whitney@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 5);
}
