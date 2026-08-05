namespace Supprocom.MathBlocks.Cuda;

internal static class ExtensionMcshaneV1BlockCuda
{
    internal const string Identity = "extension.mcshane@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Advanced, 4);
}
