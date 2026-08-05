namespace Supprocom.MathBlocks.Cuda;

internal static class TransformHaarV1BlockCuda
{
    internal const string Identity = "transform.haar@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.SequencePath, 11);
}
