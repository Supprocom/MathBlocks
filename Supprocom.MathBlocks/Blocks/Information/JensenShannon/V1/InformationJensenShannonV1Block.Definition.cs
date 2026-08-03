namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class InformationJensenShannonV1Block
    {
        internal const string Identity = "information.jensen-shannon@1";
        internal static MathBlockOperation Create() => CreateDistributionBinary("information.jensen-shannon", MathBlockProbability.JensenShannonDivergence, certain, fair, 0.21576155433883565d);
    }
}
