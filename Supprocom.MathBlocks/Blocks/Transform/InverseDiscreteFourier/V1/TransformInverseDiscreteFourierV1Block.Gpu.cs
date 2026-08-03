namespace Supprocom.MathBlocks.Gpu;

internal static class TransformInverseDiscreteFourierV1BlockGpu
{
    internal const string Identity = "transform.inverse-discrete-fourier@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 20);
}
