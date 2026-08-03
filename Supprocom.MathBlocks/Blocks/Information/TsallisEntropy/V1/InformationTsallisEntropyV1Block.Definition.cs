namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class InformationTsallisEntropyV1Block
    {
        internal const string Identity = "information.tsallis-entropy@1";
        internal static MathBlockOperation Create() => CreateOrderedEntropy("information.tsallis-entropy", MathBlockProbability.TsallisEntropy, 2d, 0.5d);
    }
}
