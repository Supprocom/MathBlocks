namespace Supprocom.MathBlocks.Cuda;

internal static class PathLeadLagTransformV1BlockCuda
{
    internal const string Identity = "path.lead-lag-transform@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 17);
}
