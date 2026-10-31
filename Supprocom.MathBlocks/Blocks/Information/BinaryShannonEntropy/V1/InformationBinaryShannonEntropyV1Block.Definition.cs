namespace Supprocom.MathBlocks;

internal static partial class ProbabilityMathBlocks
{
    internal static class InformationBinaryShannonEntropyV1Block
    {
        internal const string Identity = "information.binary-shannon-entropy@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateScalarUnary("information.binary-shannon-entropy", MathBlockProbability.BinaryShannonEntropy, fair, 1d);
    }
}
