namespace Supprocom.MathBlocks.Cuda;

internal static class PathHysteresisV1BlockCuda
{
    internal const string Identity = "path.hysteresis@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 16);
}
