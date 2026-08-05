namespace Supprocom.MathBlocks.Cuda;

internal static class TransformInverseDiscreteFourierV1BlockCuda
{
    internal const string Identity = "transform.inverse-discrete-fourier@1";
    internal static readonly MathBlockCudaFeature Feature = new(Identity, MathBlockCudaFamily.Complex, 20);
}
