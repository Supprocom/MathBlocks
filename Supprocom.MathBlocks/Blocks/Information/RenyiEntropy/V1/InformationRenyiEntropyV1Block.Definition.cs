namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class InformationRenyiEntropyV1Block
    {
        internal const string Identity = "information.renyi-entropy@1";
        internal static MathBlockOperation Create() => CreateOrderedEntropy("information.renyi-entropy", MathBlockProbability.RenyiEntropy, 2d, Math.Log(2d));
    }
}
