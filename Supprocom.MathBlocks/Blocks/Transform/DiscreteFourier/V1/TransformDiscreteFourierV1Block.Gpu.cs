namespace Supprocom.MathBlocks.Gpu;

internal static class TransformDiscreteFourierV1BlockGpu
{
    internal const string Identity = "transform.discrete-fourier@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Complex, 19);
}
