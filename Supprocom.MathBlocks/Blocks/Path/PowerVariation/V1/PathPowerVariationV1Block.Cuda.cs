namespace Supprocom.MathBlocks.Cuda;

internal static class PathPowerVariationV1BlockCuda
{
    internal const string Identity = "path.power-variation@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 21);
}
