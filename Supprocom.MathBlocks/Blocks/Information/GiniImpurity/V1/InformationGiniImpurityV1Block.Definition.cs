namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class InformationGiniImpurityV1Block
    {
        internal const string Identity = "information.gini-impurity@1";
        internal static MathBlockOperation Create() => CreateScalarUnary("information.gini-impurity", MathBlockProbability.GiniImpurity, fair, 0.5d);
    }
}
