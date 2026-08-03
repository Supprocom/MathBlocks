namespace Supprocom.MathBlocks.Gpu;

internal static class InformationBinaryShannonEntropyV1BlockGpu
{
    internal const string Identity = "information.binary-shannon-entropy@1";
    internal static readonly MathBlockGpuFeature Feature = new(Identity, MathBlockGpuFamily.Probability, 5);
}
