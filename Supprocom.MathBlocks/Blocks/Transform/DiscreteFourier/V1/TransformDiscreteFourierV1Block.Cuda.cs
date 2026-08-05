namespace Supprocom.MathBlocks.Cuda;

internal static class TransformDiscreteFourierV1BlockCuda
{
    internal const string Identity = "transform.discrete-fourier@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 19);
}
